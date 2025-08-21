output "project_id" {
  description = "Supabase Project ID"
  value       = supabase_project.whisky_hikes.id
}

output "project_name" {
  description = "Supabase Project Name"
  value       = supabase_project.whisky_hikes.name
}

output "organization_id" {
  description = "Organization ID"
  value       = supabase_project.whisky_hikes.organization_id
}

output "region" {
  description = "Project Region"
  value       = supabase_project.whisky_hikes.region
}

output "anon_key" {
  description = "Supabase Anonymous Key"
  value       = data.supabase_apikeys.whisky_hikes.anon_key
  sensitive   = true
}

output "service_role_key" {
  description = "Supabase Service Role Key"
  value       = data.supabase_apikeys.whisky_hikes.service_role_key
  sensitive   = true
}

output "project_url" {
  description = "Supabase Project URL"
  value       = "https://${supabase_project.whisky_hikes.id}.supabase.co"
}

output "deployment_status" {
  description = "Deployment completion status"
  value       = "Supabase project created successfully - run 'make schema && make policies' to setup database"
}