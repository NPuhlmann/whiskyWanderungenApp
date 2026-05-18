-- =============================================================================
-- Admin-Rolle: profiles.role + is_admin() Helper + Admin-RLS-Policies
-- =============================================================================
-- Vor dieser Migration prüften Admin-Policies gegen
-- auth.users.raw_user_meta_data->>'role' bzw. den Supabase service_role-Claim.
-- Beides ist für eine echte App-Rollenverwaltung ungeeignet (Metadata kann der
-- User selbst überschreiben, service_role ist nur server-seitig verfügbar).
--
-- Diese Migration:
--   1. ergänzt public.profiles um eine role-Spalte ('user' | 'admin')
--   2. sorgt dafür, dass neu angelegte Profile defaultmäßig role='user' erhalten
--   3. liefert eine SECURITY DEFINER Funktion public.is_admin()
--   4. ersetzt die alten Admin-Policies durch is_admin()-basierte
--   5. ergänzt Admin-Overrides auf den Multi-Vendor-Tabellen
--      (companies, tasting_sets, whisky_samples, shipping rules)
-- -----------------------------------------------------------------------------

-- 1) profiles.role -----------------------------------------------------------

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'public'
          AND table_name   = 'profiles'
          AND constraint_name = 'profiles_role_check'
    ) THEN
        ALTER TABLE public.profiles
            ADD CONSTRAINT profiles_role_check
            CHECK (role IN ('user', 'admin'));
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- 2) handle_new_user(): Default-Rolle 'user' beim Erstanlegen ----------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id, first_name, last_name, email, role, created_at, updated_at
    ) VALUES (
        NEW.id, '', '', NEW.email, 'user', NOW(), NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 3) is_admin() Helper -------------------------------------------------------
-- SECURITY DEFINER, damit die Funktion innerhalb von RLS-Policies auf
-- profiles zugreifen darf, ohne Rekursion oder erneute Policy-Prüfung
-- auszulösen.

CREATE OR REPLACE FUNCTION public.is_admin(uid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = uid AND role = 'admin'
    );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin(UUID) TO authenticated, anon;

-- 4) Profiles: Admins sehen alle Profile -------------------------------------

DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
CREATE POLICY "Admins can read all profiles" ON public.profiles
    FOR SELECT USING (public.is_admin());

-- 5) Alte Admin-Policies durch is_admin()-basierte ersetzen ------------------

DROP POLICY IF EXISTS "Admins can manage hikes" ON public.hikes;
CREATE POLICY "Admins can manage hikes" ON public.hikes
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage waypoints" ON public.waypoints;
CREATE POLICY "Admins can manage waypoints" ON public.waypoints
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage hike-waypoint relationships"
    ON public.hikes_waypoints;
CREATE POLICY "Admins can manage hike-waypoint relationships"
    ON public.hikes_waypoints
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage hike images" ON public.hike_images;
CREATE POLICY "Admins can manage hike images" ON public.hike_images
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 6) Tasting Sets & Whisky Samples: Admin-Override ---------------------------

DROP POLICY IF EXISTS "Admins can manage tasting sets" ON public.tasting_sets;
CREATE POLICY "Admins can manage tasting sets" ON public.tasting_sets
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage whisky samples" ON public.whisky_samples;
CREATE POLICY "Admins can manage whisky samples" ON public.whisky_samples
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 7) Companies & Shipping Rules: Admin-Override ------------------------------

DROP POLICY IF EXISTS "Admins can manage companies" ON public.companies;
CREATE POLICY "Admins can manage companies" ON public.companies
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage company shipping rules"
    ON public.company_shipping_rules;
CREATE POLICY "Admins can manage company shipping rules"
    ON public.company_shipping_rules
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage default shipping rules"
    ON public.default_shipping_rules;
CREATE POLICY "Admins can manage default shipping rules"
    ON public.default_shipping_rules
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 8) Storage: hike-images Bucket darf von Admins verwaltet werden ------------
-- Die bisherigen Policies forderten den service_role-Claim, der aus dem Client
-- heraus nicht verfügbar ist. Wir ersetzen sie durch is_admin().

DROP POLICY IF EXISTS "Admins can upload hike images" ON storage.objects;
CREATE POLICY "Admins can upload hike images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'hike-images' AND public.is_admin()
    );

DROP POLICY IF EXISTS "Admins can update hike images" ON storage.objects;
CREATE POLICY "Admins can update hike images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'hike-images' AND public.is_admin()
    );

DROP POLICY IF EXISTS "Admins can delete hike images" ON storage.objects;
CREATE POLICY "Admins can delete hike images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'hike-images' AND public.is_admin()
    );

COMMENT ON COLUMN public.profiles.role IS
    'Application-Rolle. "user" (Default) oder "admin". Admin gewährt Schreibrechte auf hikes, waypoints, tasting_sets, companies sowie den hike-images Storage-Bucket.';
COMMENT ON FUNCTION public.is_admin(UUID) IS
    'true, wenn der gegebene User (Default: auth.uid()) in public.profiles role=''admin'' hat. SECURITY DEFINER, damit aus RLS-Policies aufrufbar ohne Rekursion.';

-- 9) Schutz: Niemand außer Admins darf profiles.role ändern -----------------
-- Die existierende "Users can update own profile" Policy ist zeilenbasiert
-- und erlaubt deshalb auch ein UPDATE von role auf der eigenen Zeile.
-- Wir verhindern das per Trigger: wenn role geändert wird und der Aufrufer
-- ist kein Admin (bzw. ist überhaupt nicht authentifiziert), schlägt das
-- UPDATE fehl. SECURITY DEFINER Funktionen wie set_user_role() umgehen den
-- Trigger nicht — sie laufen aber bewusst nur, wenn der Aufrufer Admin ist.

CREATE OR REPLACE FUNCTION public.enforce_profile_role_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role
       AND NOT public.is_admin(auth.uid()) THEN
        RAISE EXCEPTION
            'Only admins may change profiles.role (attempted on user %).',
            NEW.id
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS enforce_profile_role_change ON public.profiles;
CREATE TRIGGER enforce_profile_role_change
    BEFORE UPDATE OF role ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.enforce_profile_role_change();

-- 10) RPC: set_user_role - Admins können Rollen vergeben/entziehen ----------
-- Wird vom Team-Management-UI aufgerufen. SECURITY DEFINER ist nötig, damit
-- die Funktion an der zeilenbasierten "Users can update own profile" Policy
-- vorbei das fremde Profil updaten kann. Die eigentliche Berechtigungsprüfung
-- läuft am Funktionsanfang.

CREATE OR REPLACE FUNCTION public.set_user_role(
    target_user_id UUID,
    new_role TEXT
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    updated_row public.profiles;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_admin(auth.uid()) THEN
        RAISE EXCEPTION 'Only admins may change user roles'
            USING ERRCODE = '42501';
    END IF;
    IF new_role NOT IN ('user', 'admin') THEN
        RAISE EXCEPTION 'Invalid role %, must be ''user'' or ''admin''',
            new_role USING ERRCODE = '22023';
    END IF;
    IF target_user_id = auth.uid() AND new_role <> 'admin' THEN
        RAISE EXCEPTION 'Admins may not demote themselves'
            USING ERRCODE = '42501';
    END IF;

    UPDATE public.profiles
       SET role = new_role,
           updated_at = NOW()
     WHERE id = target_user_id
    RETURNING * INTO updated_row;

    IF updated_row IS NULL THEN
        RAISE EXCEPTION 'No profile found for user %', target_user_id
            USING ERRCODE = 'P0002';
    END IF;
    RETURN updated_row;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_user_role(UUID, TEXT) TO authenticated;

COMMENT ON FUNCTION public.set_user_role(UUID, TEXT) IS
    'Setzt profiles.role für target_user_id. Erlaubt nur, wenn aufrufender User Admin ist. Self-Demotion vom letzten Admin wird blockiert.';
