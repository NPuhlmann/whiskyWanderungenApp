-- Erstelle die Tabellen für die Whisky Hikes App
-- Basierend auf den Flutter-Modellen: Hike, Profile, Waypoint

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles Tabelle (erweitert die auth.users Tabelle)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    first_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    date_of_birth DATE,
    email TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hikes Tabelle
CREATE TABLE IF NOT EXISTS public.hikes (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    length DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    steep DOUBLE PRECISION NOT NULL DEFAULT 0.2,
    elevation INTEGER NOT NULL DEFAULT 100,
    description TEXT DEFAULT '',
    price DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    difficulty TEXT NOT NULL DEFAULT 'mid' CHECK (difficulty IN ('easy', 'mid', 'hard', 'very_hard')),
    thumbnail_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Waypoints Tabelle
CREATE TABLE IF NOT EXISTS public.waypoints (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    images TEXT[] DEFAULT '{}',
    is_visited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Junction Tabelle für Hikes und Waypoints (Many-to-Many)
CREATE TABLE IF NOT EXISTS public.hikes_waypoints (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    waypoint_id INTEGER REFERENCES public.waypoints(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(hike_id, waypoint_id)
);

-- Purchased Hikes Tabelle (Many-to-Many zwischen Users und Hikes)
CREATE TABLE IF NOT EXISTS public.purchased_hikes (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, hike_id)
);

-- Hike Images Tabelle
CREATE TABLE IF NOT EXISTS public.hike_images (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Waypoint Visits Tabelle (für Tracking besuchter Wegpunkte)
CREATE TABLE IF NOT EXISTS public.user_waypoint_visits (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    waypoint_id INTEGER REFERENCES public.waypoints(id) ON DELETE CASCADE,
    visited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, waypoint_id)
);

-- Indexe für bessere Performance
CREATE INDEX IF NOT EXISTS idx_profiles_id ON public.profiles(id);
CREATE INDEX IF NOT EXISTS idx_hikes_id ON public.hikes(id);
CREATE INDEX IF NOT EXISTS idx_waypoints_id ON public.waypoints(id);
CREATE INDEX IF NOT EXISTS idx_hikes_waypoints_hike_id ON public.hikes_waypoints(hike_id);
CREATE INDEX IF NOT EXISTS idx_hikes_waypoints_waypoint_id ON public.hikes_waypoints(waypoint_id);
CREATE INDEX IF NOT EXISTS idx_hikes_waypoints_hike_id_order ON public.hikes_waypoints(hike_id, order_index);
CREATE INDEX IF NOT EXISTS idx_purchased_hikes_user_id ON public.purchased_hikes(user_id);
CREATE INDEX IF NOT EXISTS idx_purchased_hikes_hike_id ON public.purchased_hikes(hike_id);
CREATE INDEX IF NOT EXISTS idx_hike_images_hike_id ON public.hike_images(hike_id);
CREATE INDEX IF NOT EXISTS idx_user_waypoint_visits_user_id ON public.user_waypoint_visits(user_id);
CREATE INDEX IF NOT EXISTS idx_user_waypoint_visits_waypoint_id ON public.user_waypoint_visits(waypoint_id);

-- Trigger für updated_at Timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hikes_updated_at BEFORE UPDATE ON public.hikes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_waypoints_updated_at BEFORE UPDATE ON public.waypoints
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 
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
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

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