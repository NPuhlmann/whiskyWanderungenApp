-- Supabase SQL Trigger: Automatische Profil-Erstellung bei Benutzer-Registrierung

-- Diese SQL-Trigger-Funktion wird automatisch ausgeführt, wenn ein neuer Benutzer
-- in der auth.users Tabelle erstellt wird (bei der Registrierung)

-- 1. Erstelle die Funktion, die das Profil erstellt
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Erstelle ein neues Profil mit der Benutzer-ID aus auth.users
  INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,           -- Verwende die ID aus auth.users
    '',               -- Leerer Vorname (wird später vom Benutzer ausgefüllt)
    '',               -- Leerer Nachname (wird später vom Benutzer ausgefüllt)
    NOW(),            -- Aktueller Zeitstempel für created_at
    NOW()             -- Aktueller Zeitstempel für updated_at
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Erstelle den Trigger, der die Funktion bei neuen Benutzern ausführt
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3. Stelle sicher, dass die RLS (Row Level Security) Policy für profiles existiert
-- Diese Policy erlaubt es Benutzern, nur ihre eigenen Profile zu lesen und zu bearbeiten

-- Policy für das Lesen eigener Profile
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

-- Policy für das Aktualisieren eigener Profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id);

-- Policy für das Einfügen eigener Profile (wird vom Trigger benötigt)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

-- 4. Aktiviere RLS für die profiles Tabelle
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Wichtige Hinweise:
-- - Dieser Trigger wird automatisch ausgeführt, wenn sich ein neuer Benutzer registriert
-- - Das Profil wird mit der gleichen ID wie der Benutzer in auth.users erstellt
-- - Vorname und Nachname sind zunächst leer und können später vom Benutzer ausgefüllt werden
-- - Die RLS-Policies stellen sicher, dass Benutzer nur auf ihre eigenen Profile zugreifen können

-- Um diesen Trigger zu installieren:
-- 1. Melde dich in deinem Supabase Dashboard an
-- 2. Gehe zum SQL Editor
-- 3. Kopiere und füge diesen gesamten Code ein
-- 4. Führe das Skript aus

-- Um zu testen:
-- 1. Registriere einen neuen Benutzer über deine App
-- 2. Überprüfe die profiles Tabelle - es sollte automatisch ein Profil erstellt werden