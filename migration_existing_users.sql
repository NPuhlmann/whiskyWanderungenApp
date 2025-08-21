-- Migration: Profile für bereits bestehende Benutzer erstellen
-- Dieses Skript erstellt Profile für alle Benutzer in auth.users, die noch kein Profil haben

-- Erstelle Profile für Benutzer ohne existierende Profile
INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    created_at,
    updated_at
)
SELECT 
    u.id,
    '',                    -- Leerer Vorname
    '',                    -- Leerer Nachname  
    u.created_at,         -- Verwende das Erstellungsdatum des Benutzers
    NOW()                 -- Aktueller Zeitstempel für updated_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL        -- Nur Benutzer ohne existierende Profile
  AND u.email_confirmed_at IS NOT NULL;  -- Nur bestätigte Benutzer

-- Zeige die Anzahl der erstellten Profile an
SELECT 
    'Profile erstellt für ' || COUNT(*) || ' bestehende Benutzer' as result
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NOT NULL;

-- Wichtige Hinweise:
-- 1. Führe zuerst den Haupt-Trigger aus (supabase_trigger_profile_creation.sql)
-- 2. Dann führe dieses Migrationsskript aus
-- 3. Alle zukünftigen Registrierungen werden automatisch Profile haben
-- 4. Bestehende Benutzer erhalten hiermit ihre Profile nachträglich

-- Um das Skript auszuführen:
-- 1. Gehe zum Supabase SQL Editor
-- 2. Kopiere und füge diesen Code ein
-- 3. Führe das Skript aus
-- 4. Überprüfe das Ergebnis in der profiles Tabelle