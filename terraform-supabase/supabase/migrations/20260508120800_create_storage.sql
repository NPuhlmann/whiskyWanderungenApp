-- Erstelle Storage Buckets für die Whisky Hikes App

-- Erstelle den avatars Bucket für Profilbilder
INSERT INTO storage.buckets (id, name, public, created_at, updated_at)
VALUES ('avatars', 'avatars', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Erstelle den hike-images Bucket für Wanderungsbilder
INSERT INTO storage.buckets (id, name, public, created_at, updated_at)
VALUES ('hike-images', 'hike-images', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- storage.objects already has RLS enabled by default in Supabase; the
-- ALTER TABLE here would fail because the postgres role doesn't own
-- storage.objects (it's owned by supabase_storage_admin).