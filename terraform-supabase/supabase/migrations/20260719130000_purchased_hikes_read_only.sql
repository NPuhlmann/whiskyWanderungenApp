-- purchased_hikes read-only für Clients (#93)
--
-- Die INSERT-Policy prüfte nur die Zeilenzugehörigkeit — keinerlei
-- Zahlungsprüfung. Jeder Besitzer des gebundelten Anon-Keys plus eigenem
-- User-JWT konnte sich per PostgREST beliebige Hikes gratis freischalten.
-- purchased_hikes ist die Entitlement-Autorität der App ("My Hikes",
-- Zugriffsprüfungen) und darf nur noch serverseitig beschrieben werden.
--
-- Bewusste Regression (Maintainer-Entscheid in #93): Der Client-Kaufpfad
-- ist damit tot, bis das serverseitige Settlement (#57) Rows über
-- service_role anlegt. Diese Policies NICHT wiederherstellen.
--
-- Die SELECT-Policy "Users can view own purchased hikes" bleibt bestehen.
-- service_role umgeht RLS und kann weiterhin schreiben.
--
-- Der Admin-Cascade-Delete in HikeService.deleteHike verliert seinen
-- expliziten purchased_hikes-Schritt (löscht fortan 0 Rows) — folgenlos,
-- weil purchased_hikes.hike_id ON DELETE CASCADE hat und der abschließende
-- hikes-Delete die Rows mitnimmt.

DROP POLICY IF EXISTS "Users can purchase hikes" ON public.purchased_hikes;
DROP POLICY IF EXISTS "Users can delete own purchased hikes"
    ON public.purchased_hikes;

-- Ohne DELETE-Policy wäre ein Client-DELETE nur ein stiller 0-Rows-No-op
-- (RLS filtert, lehnt aber nicht ab). Der REVOKE macht INSERT/UPDATE/DELETE
-- zu einem harten Permission-Fehler (42501), wie das Issue es verlangt.
-- SELECT bleibt gegrantet; service_role behält seine Grants und schreibt
-- weiterhin.
REVOKE INSERT, UPDATE, DELETE ON public.purchased_hikes
    FROM anon, authenticated;
