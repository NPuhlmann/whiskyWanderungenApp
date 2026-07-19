-- Security-Härtung für Entitlement- und Order-Tabellen (#93, #94)
--
-- #93: purchased_hikes war client-INSERTbar — jeder authentifizierte User
--      konnte sich per PostgREST beliebige Hikes freischalten. Die Tabelle
--      ist die Entitlement-Quelle für "My Hikes" und darf nur noch
--      serverseitig geschrieben werden. service_role umgeht RLS, d.h. die
--      künftige Payment-Webhook-Edge-Function (#57) braucht keine Policy.
--      Der Client-Schreibpfad (recordHikePurchase) hat keine Produktions-
--      Aufrufer und läuft ab jetzt in einen RLS-Fehler.
--
-- #94: "Users can update their own orders" / "... enhanced orders" hatten
--      keinen Spaltenschutz — ein Kunde konnte seine Order auf
--      status='delivered' oder total_amount=0 patchen. Updates laufen ab
--      jetzt über service_role. Einzige legitime Client-Ausnahme: die App
--      lässt Kunden eine eigene pending/confirmed-Order stornieren
--      (order_tracking_view_model → PaymentRepository.updateOrderStatus,
--      schreibt nur status + updated_at). Genau diese Transition bleibt
--      erlaubt — per Trigger, weil RLS OLD und NEW nicht vergleichen kann.
--      enhanced_orders hat keinen legitimen Client-Update-Pfad
--      (Storno dort ist UnimplementedError): Policy ersatzlos weg.

-- #93: Entitlement-Tabelle nur noch serverseitig beschreibbar ---------------
-- Auch die DELETE-Policy fällt: "nur noch serverseitig schreiben" schließt
-- Löschen ein. hike_service.deleteHike löscht ab jetzt 0 Rows in
-- purchased_hikes — das tat es für fremde Käufe schon immer (Policy war
-- auf eigene Rows beschränkt).

DROP POLICY IF EXISTS "Users can purchase hikes" ON public.purchased_hikes;
DROP POLICY IF EXISTS "Users can delete own purchased hikes"
    ON public.purchased_hikes;

-- #94: enhanced_orders — kein Client-Update mehr ----------------------------

DROP POLICY IF EXISTS "Users can update their own enhanced orders"
    ON public.enhanced_orders;

-- #94: orders — Kunden dürfen nur noch stornieren ---------------------------

DROP POLICY IF EXISTS "Users can update their own orders" ON public.orders;

CREATE POLICY "Users can cancel their own orders" ON public.orders
    FOR UPDATE USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND status = 'cancelled');

-- Spalten- und Transitionsschutz: ein Kunde (Row-Owner, kein Admin) darf
-- ausschließlich pending/confirmed → cancelled setzen und dabei nur
-- status und updated_at anfassen. Der Spaltenvergleich läuft über
-- to_jsonb, damit künftige ALTER TABLE ... ADD COLUMN automatisch
-- geschützt sind (fail closed) statt still kundeneditierbar zu werden.
-- service_role und Migrationen haben auth.uid() IS NULL und bleiben
-- unberührt. Die is_admin()-Ausnahme ist heute mangels Admin-UPDATE-
-- Policy auf orders nicht erreichbar, folgt aber dem Muster von
-- enforce_profile_role_change und verhindert, dass eine künftige
-- Admin-Policy vom Trigger ausgebremst wird.
CREATE OR REPLACE FUNCTION public.enforce_order_cancel_only()
RETURNS TRIGGER AS $$
BEGIN
    IF auth.uid() IS NOT NULL
       AND auth.uid() = OLD.user_id
       AND NOT public.is_admin() THEN
        IF OLD.status NOT IN ('pending', 'confirmed')
           OR NEW.status IS DISTINCT FROM 'cancelled'
           OR (to_jsonb(NEW) - 'status' - 'updated_at')
              IS DISTINCT FROM (to_jsonb(OLD) - 'status' - 'updated_at') THEN
            RAISE EXCEPTION
                'Customers may only cancel a pending/confirmed order'
                USING ERRCODE = '42501';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON FUNCTION public.enforce_order_cancel_only() IS
    'Beschränkt UPDATEs des Row-Owners auf public.orders auf die Storno-'
    'Transition pending/confirmed → cancelled (nur status + updated_at). '
    'service_role (auth.uid() IS NULL) und Admins sind ausgenommen.';

DROP TRIGGER IF EXISTS enforce_order_cancel_only ON public.orders;
CREATE TRIGGER enforce_order_cancel_only
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.enforce_order_cancel_only();
