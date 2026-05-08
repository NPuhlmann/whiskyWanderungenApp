-- Stored Functions für erweiterte Review-Operationen
-- Performance-optimierte Funktionen für häufige Review-Abfragen

-- Funktion: Durchschnittsbewertung für einen Hike berechnen
CREATE OR REPLACE FUNCTION get_hike_average_rating(hike_id_param INTEGER)
RETURNS NUMERIC(3,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(ROUND(AVG(rating), 2), 0.0)
        FROM public.reviews 
        WHERE hike_id = hike_id_param
    );
END;
$$ LANGUAGE plpgsql;

-- Funktion: Bewertungsstatistiken für einen Hike abrufen
CREATE OR REPLACE FUNCTION get_hike_review_stats(hike_id_param INTEGER)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_reviews', COUNT(*),
        'average_rating', COALESCE(ROUND(AVG(rating), 2), 0.0),
        'rating_distribution', json_build_object(
            '5_stars', COUNT(*) FILTER (WHERE rating = 5.0),
            '4_stars', COUNT(*) FILTER (WHERE rating = 4.0),
            '3_stars', COUNT(*) FILTER (WHERE rating = 3.0),
            '2_stars', COUNT(*) FILTER (WHERE rating = 2.0),
            '1_star', COUNT(*) FILTER (WHERE rating = 1.0)
        )
    ) INTO result
    FROM public.reviews 
    WHERE hike_id = hike_id_param;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Funktion: Neueste Reviews systemweit mit Nutzerdaten abrufen
CREATE OR REPLACE FUNCTION get_recent_reviews_with_users(limit_param INTEGER DEFAULT 20)
RETURNS TABLE (
    id INTEGER,
    hike_id INTEGER,
    user_id UUID,
    rating NUMERIC(2,1),
    comment TEXT,
    created_at TIMESTAMPTZ,
    user_first_name TEXT,
    user_last_name TEXT,
    hike_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.hike_id,
        r.user_id,
        r.rating,
        r.comment,
        r.created_at,
        COALESCE(p.first_name, '') as user_first_name,
        COALESCE(p.last_name, '') as user_last_name,
        COALESCE(h.name, '') as hike_name
    FROM public.reviews r
    LEFT JOIN public.profiles p ON r.user_id = p.id
    LEFT JOIN public.hikes h ON r.hike_id = h.id
    ORDER BY r.created_at DESC
    LIMIT limit_param;
END;
$$ LANGUAGE plpgsql;

-- Funktion: Reviews für einen Hike mit Nutzerdaten abrufen
CREATE OR REPLACE FUNCTION get_reviews_for_hike_with_users(hike_id_param INTEGER)
RETURNS TABLE (
    id INTEGER,
    hike_id INTEGER,
    user_id UUID,
    rating NUMERIC(2,1),
    comment TEXT,
    created_at TIMESTAMPTZ,
    user_first_name TEXT,
    user_last_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.hike_id,
        r.user_id,
        r.rating,
        r.comment,
        r.created_at,
        COALESCE(p.first_name, '') as user_first_name,
        COALESCE(p.last_name, '') as user_last_name
    FROM public.reviews r
    LEFT JOIN public.profiles p ON r.user_id = p.id
    WHERE r.hike_id = hike_id_param
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Funktion: Prüfen ob User bereits Review für Hike erstellt hat
CREATE OR REPLACE FUNCTION has_user_reviewed_hike(hike_id_param INTEGER, user_id_param UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.reviews 
        WHERE hike_id = hike_id_param AND user_id = user_id_param
    );
END;
$$ LANGUAGE plpgsql;

-- Kommentare zur Dokumentation
COMMENT ON FUNCTION get_hike_average_rating(INTEGER) IS 'Berechnet die Durchschnittsbewertung für einen Hike';
COMMENT ON FUNCTION get_hike_review_stats(INTEGER) IS 'Liefert detaillierte Bewertungsstatistiken für einen Hike';
COMMENT ON FUNCTION get_recent_reviews_with_users(INTEGER) IS 'Ruft die neuesten Reviews systemweit mit Nutzerdaten ab';
COMMENT ON FUNCTION get_reviews_for_hike_with_users(INTEGER) IS 'Ruft alle Reviews für einen Hike mit Nutzerdaten ab';
COMMENT ON FUNCTION has_user_reviewed_hike(INTEGER, UUID) IS 'Prüft ob ein Nutzer bereits ein Review für einen Hike erstellt hat';