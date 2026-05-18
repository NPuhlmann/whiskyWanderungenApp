-- =============================================================================
-- Seed: erster Admin
-- =============================================================================
-- Setzt den Projekt-Owner nico@nico-puhlmann.de auf role='admin', sobald
-- dessen Profil existiert. Idempotent: ändert nichts, wenn die Rolle bereits
-- 'admin' ist, und tut nichts, wenn das Profil (noch) nicht existiert
-- (z. B. bei einem frisch provisionierten Projekt ohne registrierten User).
-- -----------------------------------------------------------------------------

UPDATE public.profiles
   SET role = 'admin',
       updated_at = NOW()
 WHERE email = 'nico@nico-puhlmann.de'
   AND role  <> 'admin';
