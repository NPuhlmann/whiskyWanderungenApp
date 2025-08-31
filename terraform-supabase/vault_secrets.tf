# Supabase Vault Integration für sichere Stripe-Secrets
# Dieses Modul richtet das Vault ein und speichert Stripe-Secrets sicher

# Execute Vault Setup SQL
resource "null_resource" "vault_setup" {
  triggers = {
    # Re-run if vault SQL changes
    vault_sql_hash = filemd5("${path.module}/sql/08_supabase_vault_setup.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      ${path.module}/execute_sql.sh "$(cat ${path.module}/sql/08_supabase_vault_setup.sql)"
    EOT
  }

  depends_on = [
    supabase_project.whisky_hikes,
    null_resource.payment_schema_migration
  ]
}

# Store Stripe secrets in Vault via SQL function call
resource "null_resource" "store_stripe_secrets" {
  triggers = {
    # Re-run if secrets change (use hashes to avoid exposing actual values)
    stripe_test_pub_hash    = sha256(local.stripe_publishable_key)
    stripe_test_secret_hash = sha256(local.stripe_secret_key)
    stripe_test_webhook_hash = sha256(local.stripe_webhook_secret)
    environment = var.environment
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      
      # Create SQL command to call setup function with secrets
      cat > /tmp/setup_secrets.sql << 'EOF'
SELECT setup_stripe_secrets(
  '${local.stripe_publishable_key}',
  '${local.stripe_secret_key}', 
  '${local.stripe_webhook_secret}',
  '${local.stripe_publishable_key_live}',
  '${local.stripe_secret_key_live}',
  '${local.stripe_webhook_secret_live}',
  '${var.environment}'
) AS result;
EOF
      
      # Execute the SQL
      ${path.module}/execute_sql.sh "$(cat /tmp/setup_secrets.sql)"
      
      # Clean up temporary file
      rm -f /tmp/setup_secrets.sql
    EOT
  }

  depends_on = [
    null_resource.vault_setup
  ]
}

# Test vault functionality
resource "null_resource" "test_vault_secrets" {
  triggers = {
    # Test after secrets are stored
    secrets_stored = null_resource.store_stripe_secrets.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      export SUPABASE_ACCESS_TOKEN="${var.supabase_access_token}"
      export PROJECT_ID="${supabase_project.whisky_hikes.id}"
      
      echo "🔍 Testing Vault setup..."
      ${path.module}/execute_sql.sh "SELECT test_vault_secrets() AS test_result;"
    EOT
  }

  depends_on = [
    null_resource.store_stripe_secrets
  ]
}

# Data source to verify vault setup (for outputs)
data "external" "vault_status" {
  program = ["${path.module}/check_vault_status.sh"]
  
  query = {
    project_id = supabase_project.whisky_hikes.id
    access_token = var.supabase_access_token
  }
  
  depends_on = [
    null_resource.test_vault_secrets
  ]
}

# Locals for secret management (defined in variables.tf)

# Output vault information (no sensitive data)
output "vault_setup" {
  description = "Supabase Vault setup information"
  value = {
    vault_enabled     = true
    secrets_stored    = true
    environment      = var.environment
    stripe_mode      = var.environment == "prod" && var.stripe_secret_key_live != "" ? "live" : "test"
    setup_timestamp  = timestamp()
  }
  
  depends_on = [
    null_resource.test_vault_secrets
  ]
}

# Security validation
resource "null_resource" "security_validation" {
  triggers = {
    validate_secrets = "always"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "🛡️  Performing security validation..."
      
      # Check that we're not exposing secrets in logs
      if grep -r "sk_" /tmp/terraform* 2>/dev/null | grep -v "sk_test_\*" | grep -v "sk_live_\*"; then
        echo "❌ WARNING: Potential secret exposure in temp files!"
        exit 1
      fi
      
      # Validate secret format
      if [[ ! "${local.stripe_publishable_key}" =~ ^pk_(test_|live_) ]]; then
        echo "❌ Invalid publishable key format"
        exit 1
      fi
      
      if [[ ! "${local.stripe_secret_key}" =~ ^sk_(test_|live_) ]]; then
        echo "❌ Invalid secret key format" 
        exit 1
      fi
      
      if [[ ! "${local.stripe_webhook_secret}" =~ ^whsec_ ]]; then
        echo "❌ Invalid webhook secret format"
        exit 1
      fi
      
      echo "✅ Security validation passed"
    EOT
  }
  
  depends_on = [
    null_resource.store_stripe_secrets
  ]
}