-- Erstelle die Reviews Tabelle für Hike-Bewertungen
-- Basierend auf dem Review-Model: id, hikeId, userId, rating, comment, createdAt

-- Reviews Tabelle
CREATE TABLE IF NOT EXISTS public.reviews (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER NOT NULL REFERENCES public.hikes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT NOT NULL CHECK (LENGTH(comment) > 0 AND LENGTH(comment) <= 1000),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Stelle sicher, dass ein Nutzer pro Hike nur ein Review erstellen kann
    UNIQUE(hike_id, user_id)
);

-- Index für bessere Performance bei häufigen Abfragen
CREATE INDEX IF NOT EXISTS idx_reviews_hike_id ON public.reviews(hike_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);

-- RLS (Row Level Security) aktivieren
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Trigger für automatische updated_at Aktualisierung
CREATE OR REPLACE FUNCTION update_updated_at_reviews()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_reviews();

-- Kommentare zur Dokumentation
COMMENT ON TABLE public.reviews IS 'Bewertungen und Kommentare von Nutzern zu Hikes';
COMMENT ON COLUMN public.reviews.rating IS 'Bewertung von 1.0 bis 5.0 Sternen';
COMMENT ON COLUMN public.reviews.comment IS 'Kommentar des Nutzers (max. 1000 Zeichen)';
COMMENT ON CONSTRAINT reviews_hike_id_user_id_key ON public.reviews IS 'Ein Nutzer kann pro Hike nur eine Bewertung abgeben';