-- Storage Policies für die Whisky Hikes App
-- Diese Policies ermöglichen authentifizierten Benutzern den Zugriff auf Bilder

-- Policy für den hike-images Bucket
-- Alle authentifizierten Benutzer können Bilder anzeigen
CREATE POLICY "Authenticated users can view hike images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'hike-images' 
        AND auth.role() = 'authenticated'
    );

-- Nur Admins können Bilder in den hike-images Bucket hochladen
CREATE POLICY "Admins can upload hike images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'hike-images' 
        AND auth.role() = 'authenticated'
        AND auth.jwt() ->> 'role' = 'service_role'
    );

-- Nur Admins können Bilder im hike-images Bucket aktualisieren
CREATE POLICY "Admins can update hike images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'hike-images' 
        AND auth.role() = 'authenticated'
        AND auth.jwt() ->> 'role' = 'service_role'
    );

-- Nur Admins können Bilder im hike-images Bucket löschen
CREATE POLICY "Admins can delete hike images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'hike-images' 
        AND auth.role() = 'authenticated'
        AND auth.jwt() ->> 'role' = 'service_role'
    );

-- Policy für den avatars Bucket (bereits vorhanden, aber zur Vollständigkeit)
-- Alle authentifizierten Benutzer können Profilbilder anzeigen
CREATE POLICY "Authenticated users can view avatars" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
    );

-- Benutzer können ihr eigenes Profilbild hochladen
CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Benutzer können ihr eigenes Profilbild aktualisieren
CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Benutzer können ihr eigenes Profilbild löschen
CREATE POLICY "Users can delete their own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );
