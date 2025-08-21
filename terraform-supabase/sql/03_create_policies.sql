-- Row Level Security (RLS) Policies für die Whisky Hikes App

-- Enable RLS für alle Tabellen
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hikes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waypoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hikes_waypoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchased_hikes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hike_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_waypoint_visits ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
-- Benutzer können nur ihr eigenes Profil lesen und bearbeiten
-- Diese Policies werden für die automatische Profilerstellung benötigt
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Hikes Policies
-- Alle authentifizierten Benutzer können alle Wanderungen lesen
CREATE POLICY "Authenticated users can view all hikes" ON public.hikes
    FOR SELECT USING (auth.role() = 'authenticated');

-- Nur Admins können Wanderungen erstellen, bearbeiten oder löschen
CREATE POLICY "Admins can manage hikes" ON public.hikes
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM auth.users 
            WHERE raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Waypoints Policies
-- Alle authentifizierten Benutzer können alle Wegpunkte lesen
CREATE POLICY "Authenticated users can view all waypoints" ON public.waypoints
    FOR SELECT USING (auth.role() = 'authenticated');

-- Nur Admins können Wegpunkte erstellen, bearbeiten oder löschen
CREATE POLICY "Admins can manage waypoints" ON public.waypoints
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM auth.users 
            WHERE raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Hikes Waypoints Policies
-- Alle authentifizierten Benutzer können die Verknüpfungen lesen
CREATE POLICY "Authenticated users can view hike-waypoint relationships" ON public.hikes_waypoints
    FOR SELECT USING (auth.role() = 'authenticated');

-- Nur Admins können Verknüpfungen erstellen, bearbeiten oder löschen
CREATE POLICY "Admins can manage hike-waypoint relationships" ON public.hikes_waypoints
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM auth.users 
            WHERE raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Purchased Hikes Policies
-- Benutzer können nur ihre eigenen gekauften Wanderungen sehen
CREATE POLICY "Users can view own purchased hikes" ON public.purchased_hikes
    FOR SELECT USING (auth.uid() = user_id);

-- Benutzer können ihre eigenen Wanderungen kaufen
CREATE POLICY "Users can purchase hikes" ON public.purchased_hikes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Benutzer können ihre eigenen gekauften Wanderungen löschen (Rückerstattung)
CREATE POLICY "Users can delete own purchased hikes" ON public.purchased_hikes
    FOR DELETE USING (auth.uid() = user_id);

-- Hike Images Policies
-- Alle authentifizierten Benutzer können alle Wanderungsbilder sehen
CREATE POLICY "Authenticated users can view all hike images" ON public.hike_images
    FOR SELECT USING (auth.role() = 'authenticated');

-- Nur Admins können Wanderungsbilder verwalten
CREATE POLICY "Admins can manage hike images" ON public.hike_images
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM auth.users 
            WHERE raw_user_meta_data->>'role' = 'admin'
        )
    );

-- User Waypoint Visits Policies
-- Benutzer können nur ihre eigenen Wegpunkt-Besuche sehen
CREATE POLICY "Users can view own waypoint visits" ON public.user_waypoint_visits
    FOR SELECT USING (auth.uid() = user_id);

-- Benutzer können ihre eigenen Wegpunkt-Besuche erstellen
CREATE POLICY "Users can create own waypoint visits" ON public.user_waypoint_visits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Benutzer können ihre eigenen Wegpunkt-Besuche löschen
CREATE POLICY "Users can delete own waypoint visits" ON public.user_waypoint_visits
    FOR DELETE USING (auth.uid() = user_id);

-- Storage Policies für den avatars Bucket
-- Benutzer können nur ihre eigenen Profilbilder hochladen
CREATE POLICY "Users can upload own profile images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Benutzer können nur ihre eigenen Profilbilder sehen
CREATE POLICY "Users can view own profile images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'avatars' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Benutzer können nur ihre eigenen Profilbilder aktualisieren
CREATE POLICY "Users can update own profile images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Benutzer können nur ihre eigenen Profilbilder löschen
CREATE POLICY "Users can delete own profile images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Öffentliche Leserechte für Profilbilder (für Anzeige in der App)
CREATE POLICY "Public can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars'); 