terraform {
  required_version = ">= 1.0"
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  
  # Remote state backend für Produktionsumgebung
  # Kommentiere das für lokale Entwicklung aus
  # backend "s3" {
  #   bucket = "whisky-hikes-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "supabase" {
  # Supabase Access Token - sollte als Umgebungsvariable gesetzt werden
  # export SUPABASE_ACCESS_TOKEN="your-access-token"
}

# Supabase Projekt (Free Tier)
resource "supabase_project" "whisky_hikes" {
  name                = var.project_name
  organization_id     = var.organization_id
  region             = var.region
  database_password  = var.database_password
  plan               = "free"  # Explizit Free Tier verwenden
}

# Local-exec für Supabase CLI Setup
resource "null_resource" "supabase_setup" {
  depends_on = [supabase_project.whisky_hikes]
  
  triggers = {
    project_id = supabase_project.whisky_hikes.id
    sql_hash   = filemd5("${path.module}/sql/combined.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Initializing Supabase CLI..."
      
      # Initialize Supabase in project directory
      cd ${path.module}
      
      # Link to the created project
      echo "Linking to Supabase project..."
      supabase link --project-ref ${supabase_project.whisky_hikes.id}
      
      # Apply database migrations
      echo "Applying database schema..."
      supabase db push --include-all
      
      echo "Supabase setup completed!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Supabase project will be destroyed via Terraform...'"
  }
} 