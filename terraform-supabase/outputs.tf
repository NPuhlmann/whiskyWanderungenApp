output "project_id" {
  description = "Supabase Project ID"
  value       = supabase_project.whisky_hikes.id
}

output "project_url" {
  description = "Supabase Project URL"
  value       = supabase_project.whisky_hikes.api_url
}

output "database_url" {
  description = "Database connection URL"
  value       = supabase_project.whisky_hikes.database_url
  sensitive   = true
}

output "anon_key" {
  description = "Supabase Anon Key"
  value       = supabase_project.whisky_hikes.anon_key
  sensitive   = true
}

output "service_role_key" {
  description = "Supabase Service Role Key"
  value       = supabase_project.whisky_hikes.service_role_key
  sensitive   = true
}

output "storage_bucket_name" {
  description = "Storage bucket name for avatars"
  value       = supabase_storage_bucket.avatars.name
}

output "project_status" {
  description = "Project deployment status"
  value       = supabase_project.whisky_hikes.status
} 