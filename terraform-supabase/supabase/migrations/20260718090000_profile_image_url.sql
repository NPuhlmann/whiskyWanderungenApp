-- =============================================================================
-- profiles.image_url: Avatar-URL direkt am Profil persistieren
-- =============================================================================
-- Bisher wurde imageUrl beim Profil-Save aus dem JSON gestrippt, weil die
-- Spalte fehlte. Der Avatar war nur über ein fragiles Storage list()-Lookup
-- wiederherstellbar. Diese Migration ist rein additiv (expand): sie fügt die
-- Spalte hinzu und aktualisiert handle_new_user(), damit neue Profile einen
-- leeren Default statt NULL bekommen. Keine App-Änderungen in diesem Schritt.
-- -----------------------------------------------------------------------------

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT '';

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id, first_name, last_name, email, role, image_url, created_at, updated_at
    ) VALUES (
        NEW.id, '', '', NEW.email, 'user', '', NOW(), NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON COLUMN public.profiles.image_url IS
    'Öffentliche URL des Avatar-Bilds im "avatars" Storage-Bucket. Leerer String, wenn kein Avatar hochgeladen wurde.';
