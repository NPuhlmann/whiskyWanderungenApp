-- Backfill: Profile für bestätigte Benutzer ohne Profil-Row anlegen.
--
-- Der Trigger on_auth_user_created (initial_schema) deckt nur Registrierungen
-- ab, die nach seiner Installation passiert sind. Dieser Backfill holt die
-- Bestandsnutzer nach und ist per WHERE p.id IS NULL idempotent — mehrfaches
-- Anwenden legt keine Duplikate an.
--
-- Übernommen aus dem losen Root-Skript migration_existing_users.sql; ADR-0003
-- macht dieses Verzeichnis zur einzigen Schema-Autorität.

INSERT INTO public.profiles (id, first_name, last_name, created_at, updated_at)
SELECT
    u.id,
    '',
    '',
    u.created_at,
    NOW()
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL
  AND u.email_confirmed_at IS NOT NULL;
