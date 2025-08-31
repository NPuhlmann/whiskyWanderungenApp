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

# SQL Migration für Payment-Tabellen über Supabase Management API
resource "null_resource" "payment_schema_migration" {
  triggers = {
    # Trigger bei Änderungen der SQL-Datei
    sql_content = filemd5("${path.module}/sql/05_create_payment_tables.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/05_create_payment_tables.sql)"
    EOT
  }

  depends_on = [supabase_project.whisky_hikes]
}

# SQL Migration für Multi-Vendor Companies System
resource "null_resource" "companies_schema_migration" {
  triggers = {
    # Trigger bei Änderungen der Companies SQL-Datei
    companies_sql_content = filemd5("${path.module}/sql/06_companies_system.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      echo "🏢 Setting up Multi-Vendor Companies System..."
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/06_companies_system.sql)"
    EOT
  }

  depends_on = [
    supabase_project.whisky_hikes,
    null_resource.payment_schema_migration
  ]
}

# SQL Migration für Sample Companies Data
resource "null_resource" "sample_companies_migration" {
  triggers = {
    # Trigger bei Änderungen der Sample Data
    sample_data_content = filemd5("${path.module}/sql/07_sample_companies_data.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      echo "📊 Inserting sample companies and shipping rules..."
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/07_sample_companies_data.sql)"
    EOT
  }

  depends_on = [
    null_resource.companies_schema_migration
  ]
}

# SQL Migration für Storage Policies
resource "null_resource" "storage_policies_migration" {
  triggers = {
    # Trigger bei Änderungen der Storage Policies
    storage_policies_content = filemd5("${path.module}/sql/09_storage_policies.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      echo "🔐 Setting up Storage Policies..."
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/09_storage_policies.sql)"
    EOT
  }

  depends_on = [
    supabase_project.whisky_hikes
  ]
}

# Upload der Sample Images
resource "null_resource" "sample_images_upload" {
  triggers = {
    # Trigger bei Änderungen der Sample Images
    sample_images_content = filemd5("${path.module}/upload_sample_images.sh")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      export SUPABASE_URL="https://${supabase_project.whisky_hikes.id}.supabase.co"
      export SUPABASE_SERVICE_ROLE_KEY="${var.supabase_service_role_key}"
      echo "🖼️  Uploading Sample Images..."
      ${path.module}/upload_sample_images.sh
    EOT
  }

  depends_on = [
    null_resource.storage_policies_migration
  ]
}

# SQL Migration für Hike Images Update
resource "null_resource" "hike_images_update" {
  triggers = {
    # Trigger bei Änderungen der Hike Images SQL
    hike_images_content = filemd5("${path.module}/sql/10_update_hike_images.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      echo "🖼️  Updating Hike Images with Sample Images..."
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/10_update_hike_images.sql)"
    EOT
  }

  depends_on = [
    null_resource.sample_images_upload
  ]
}

# Note: Database schema is created via Management API scripts
# See: complete_schema.sh, create_policies.sh, insert_sample_data.sh