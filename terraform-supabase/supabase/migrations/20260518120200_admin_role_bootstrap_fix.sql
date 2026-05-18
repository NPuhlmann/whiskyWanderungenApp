-- =============================================================================
-- Fix Bootstrap: Trigger nur für authentifizierte User-Sessions greifen lassen
-- =============================================================================
-- Im Supabase-Dashboard-SQL-Editor (oder bei Migrationen) ist auth.uid()
-- NULL — der Anti-Self-Promotion-Trigger blockte deshalb auch legitime
-- Admin-Bootstrap-UPDATEs. Wir lassen den Trigger nur noch greifen, wenn
-- ein User-JWT vorliegt, und führen anschließend den Seed nochmal aus
-- (idempotent), falls das Profil zwischen den ersten Migrationen und
-- dem ersten Login angelegt wurde.

CREATE OR REPLACE FUNCTION public.enforce_profile_role_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role
       AND auth.uid() IS NOT NULL
       AND NOT public.is_admin(auth.uid()) THEN
        RAISE EXCEPTION
            'Only admins may change profiles.role (attempted on user %).',
            NEW.id
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

UPDATE public.profiles
   SET role = 'admin',
       updated_at = NOW()
 WHERE email = 'nico@nico-puhlmann.de'
   AND role  <> 'admin';
