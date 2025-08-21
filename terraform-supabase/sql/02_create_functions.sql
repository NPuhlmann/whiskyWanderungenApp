-- Hilfsfunktionen für die Whisky Hikes App

-- Funktion zum Erstellen eines Profils für neue Benutzer
-- Diese Funktion wird automatisch ausgeführt, wenn sich ein neuer Benutzer registriert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Erstelle ein neues Profil mit der Benutzer-ID und E-Mail aus auth.users
    INSERT INTO public.profiles (
        id,
        first_name,
        last_name,
        email,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,           -- Verwende die ID aus auth.users
        '',               -- Leerer Vorname (wird später vom Benutzer ausgefüllt)
        '',               -- Leerer Nachname (wird später vom Benutzer ausgefüllt)
        NEW.email,        -- E-Mail aus auth.users
        NOW(),            -- Aktueller Zeitstempel für created_at
        NOW()             -- Aktueller Zeitstempel für updated_at
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger für neue Benutzer
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Funktion zum Kaufen einer Wanderung
CREATE OR REPLACE FUNCTION public.purchase_hike(hike_id_param INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- Aktuellen Benutzer abrufen
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Nicht authentifiziert';
    END IF;
    
    -- Prüfen ob die Wanderung bereits gekauft wurde
    IF EXISTS (
        SELECT 1 FROM public.purchased_hikes 
        WHERE user_id = current_user_id AND hike_id = hike_id_param
    ) THEN
        RETURN FALSE; -- Bereits gekauft
    END IF;
    
    -- Wanderung kaufen
    INSERT INTO public.purchased_hikes (user_id, hike_id)
    VALUES (current_user_id, hike_id_param);
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Markieren eines Wegpunkts als besucht
CREATE OR REPLACE FUNCTION public.visit_waypoint(waypoint_id_param INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- Aktuellen Benutzer abrufen
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Nicht authentifiziert';
    END IF;
    
    -- Prüfen ob der Wegpunkt bereits besucht wurde
    IF EXISTS (
        SELECT 1 FROM public.user_waypoint_visits 
        WHERE user_id = current_user_id AND waypoint_id = waypoint_id_param
    ) THEN
        RETURN FALSE; -- Bereits besucht
    END IF;
    
    -- Wegpunkt als besucht markieren
    INSERT INTO public.user_waypoint_visits (user_id, waypoint_id)
    VALUES (current_user_id, waypoint_id_param);
    
    -- is_visited in waypoints Tabelle aktualisieren
    UPDATE public.waypoints 
    SET is_visited = TRUE 
    WHERE id = waypoint_id_param;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Abrufen der Wanderungen eines Benutzers mit Wegpunkten
CREATE OR REPLACE FUNCTION public.get_user_hikes_with_waypoints()
RETURNS TABLE (
    hike_id INTEGER,
    hike_name TEXT,
    hike_description TEXT,
    hike_length DOUBLE PRECISION,
    hike_difficulty TEXT,
    waypoint_id INTEGER,
    waypoint_name TEXT,
    waypoint_description TEXT,
    waypoint_latitude DOUBLE PRECISION,
    waypoint_longitude DOUBLE PRECISION,
    waypoint_visited BOOLEAN
) AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Nicht authentifiziert';
    END IF;
    
    RETURN QUERY
    SELECT 
        h.id as hike_id,
        h.name as hike_name,
        h.description as hike_description,
        h.length as hike_length,
        h.difficulty as hike_difficulty,
        w.id as waypoint_id,
        w.name as waypoint_name,
        w.description as waypoint_description,
        w.latitude as waypoint_latitude,
        w.longitude as waypoint_longitude,
        COALESCE(uwv.visited_at IS NOT NULL, FALSE) as waypoint_visited
    FROM public.purchased_hikes ph
    JOIN public.hikes h ON ph.hike_id = h.id
    LEFT JOIN public.hikes_waypoints hw ON h.id = hw.hike_id
    LEFT JOIN public.waypoints w ON hw.waypoint_id = w.id
    LEFT JOIN public.user_waypoint_visits uwv ON w.id = uwv.waypoint_id AND uwv.user_id = current_user_id
    WHERE ph.user_id = current_user_id
    ORDER BY h.id, w.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Abrufen der Statistiken eines Benutzers
CREATE OR REPLACE FUNCTION public.get_user_stats()
RETURNS TABLE (
    total_hikes INTEGER,
    completed_hikes INTEGER,
    total_waypoints INTEGER,
    visited_waypoints INTEGER,
    total_distance DOUBLE PRECISION
) AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Nicht authentifiziert';
    END IF;
    
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT ph.hike_id)::INTEGER as total_hikes,
        COUNT(DISTINCT CASE WHEN hike_waypoints.visited_count = hike_waypoints.total_waypoints THEN ph.hike_id END)::INTEGER as completed_hikes,
        COALESCE(SUM(hike_waypoints.total_waypoints), 0)::INTEGER as total_waypoints,
        COUNT(DISTINCT uwv.waypoint_id)::INTEGER as visited_waypoints,
        COALESCE(SUM(h.length), 0.0) as total_distance
    FROM public.purchased_hikes ph
    JOIN public.hikes h ON ph.hike_id = h.id
    LEFT JOIN (
        SELECT 
            hw.hike_id,
            COUNT(w.id) as total_waypoints,
            COUNT(uwv.waypoint_id) as visited_count
        FROM public.hikes_waypoints hw
        JOIN public.waypoints w ON hw.waypoint_id = w.id
        LEFT JOIN public.user_waypoint_visits uwv ON w.id = uwv.waypoint_id AND uwv.user_id = current_user_id
        GROUP BY hw.hike_id
    ) hike_waypoints ON h.id = hike_waypoints.hike_id
    LEFT JOIN public.user_waypoint_visits uwv ON uwv.user_id = current_user_id
    WHERE ph.user_id = current_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 