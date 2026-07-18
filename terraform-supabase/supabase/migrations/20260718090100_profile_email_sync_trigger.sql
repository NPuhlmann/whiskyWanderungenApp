-- =============================================================================
-- profiles.email als self-healing Projektion von auth.users.email
-- =============================================================================
-- profiles.email wurde bisher nur einmal bei der Registrierung von
-- handle_new_user() gesetzt und danach nie wieder aktualisiert. Die App
-- strippt email bewusst aus jedem Profil-Write (siehe ADR-0010) und
-- aktualisiert die auth-seitige E-Mail separat - dadurch driftete
-- profiles.email nach jeder E-Mail-Änderung. Dieser Trigger hält die Spalte
-- unabhängig vom Änderungsweg (App, Supabase Admin UI, künftige Flows)
-- synchron. Rein additiv (expand), keine App-Änderungen in diesem Schritt.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.sync_profile_email()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.profiles
       SET email = NEW.email,
           updated_at = NOW()
     WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS sync_profile_email ON auth.users;
CREATE TRIGGER sync_profile_email
    AFTER UPDATE OF email ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.sync_profile_email();

COMMENT ON FUNCTION public.sync_profile_email() IS
    'Hält profiles.email synchron mit auth.users.email. SECURITY DEFINER, da authenticated/anon nicht auf auth.users lesen dürfen (siehe ADR-0010).';
