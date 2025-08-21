terraform {
  required_version = ">= 1.0"
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }
}

provider "supabase" {
  # Supabase Access Token wird aus der Umgebungsvariable SUPABASE_ACCESS_TOKEN gelesen
}

# Supabase Projekt erstellen
resource "supabase_project" "whisky_hikes" {
  name                = var.project_name
  organization_id     = var.organization_id
  region             = var.region
  database_password  = var.database_password
}

# Data source für API Keys
data "supabase_apikeys" "whisky_hikes" {
  project_ref = supabase_project.whisky_hikes.id
}

# Note: Database schema is created via Management API scripts
# See: complete_schema.sh, create_policies.sh, insert_sample_data.sh