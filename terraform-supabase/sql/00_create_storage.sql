-- Erstelle Storage Buckets für die Whisky Hikes App

-- Erstelle den avatars Bucket für Profilbilder
INSERT INTO storage.buckets (id, name, public, created_at, updated_at)
VALUES ('avatars', 'avatars', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Erstelle den hike-images Bucket für Wanderungsbilder
INSERT INTO storage.buckets (id, name, public, created_at, updated_at)
VALUES ('hike-images', 'hike-images', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Aktiviere RLS für den Storage
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;