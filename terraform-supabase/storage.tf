# Storage Bucket Configuration
# Diese Datei definiert Storage-Buckets für die Whisky Hikes App

# Storage Bucket für Profilbilder
resource "null_resource" "setup_storage" {
  depends_on = [null_resource.supabase_setup]
  
  triggers = {
    project_id = supabase_project.whisky_hikes.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Setting up storage buckets..."
      
      # Storage Setup über Supabase CLI
      cd ${path.module}
      
      # Create storage configuration
      mkdir -p supabase/storage
      
      # Create avatars bucket configuration
      cat > supabase/storage/buckets.sql << 'EOF'
-- Storage Buckets Setup for Whisky Hikes

-- Create avatars bucket for profile images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars', 
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Create hike-images bucket for hike photos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'hike-images',
  'hike-images',
  true,
  10485760, -- 10MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;
EOF

      # Apply storage configuration
      supabase db push --include-all
      
      echo "Storage buckets created successfully!"
    EOT
  }
}

# Storage Policies Setup
resource "local_file" "storage_policies" {
  filename = "${path.module}/supabase/storage/policies.sql"
  content = <<-EOF
-- Storage Policies für Whisky Hikes App

-- Avatars Bucket Policies
-- Users can upload their own profile images
CREATE POLICY "Users can upload own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can view their own profile images
CREATE POLICY "Users can view own profile images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update their own profile images
CREATE POLICY "Users can update own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can delete their own profile images
CREATE POLICY "Users can delete own profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Public read access for all profile images (for display in app)
CREATE POLICY "Public can view all profile images" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Hike Images Bucket Policies
-- Public read access for hike images
CREATE POLICY "Public can view hike images" ON storage.objects
  FOR SELECT USING (bucket_id = 'hike-images');

-- Only admins can manage hike images
CREATE POLICY "Admins can manage hike images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'hike-images' AND
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    )
  );
EOF
}