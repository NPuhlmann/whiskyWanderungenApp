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