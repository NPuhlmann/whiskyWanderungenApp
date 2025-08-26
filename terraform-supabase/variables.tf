# Terraform Variables für Whisky Hikes Multi-Vendor System
# Diese Variablen werden aus .env und terraform.tfvars gelesen

# === SUPABASE CONFIGURATION ===
variable "supabase_access_token" {
  description = "Supabase Management API access token"
  type        = string
  sensitive   = true
}

variable "organization_id" {
  description = "Supabase Organization ID"
  type        = string
}

variable "region" {
  description = "Supabase project region"
  type        = string
  default     = "eu-central-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-west-1", "eu-west-1", "eu-central-1", 
      "ap-northeast-1", "ap-southeast-1", "ap-southeast-2"
    ], var.region)
    error_message = "Region must be a valid Supabase region."
  }
}

variable "database_password" {
  description = "Database password for the Supabase project"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.database_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "project_name" {
  description = "Name of the Supabase project"
  type        = string
  default     = "whisky-hikes"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# === STRIPE CONFIGURATION (Test Keys) ===
variable "stripe_publishable_key_test" {
  description = "Stripe publishable key for test environment"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^pk_test_", var.stripe_publishable_key_test))
    error_message = "Stripe test publishable key must start with 'pk_test_'."
  }
}

variable "stripe_secret_key_test" {
  description = "Stripe secret key for test environment"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^sk_test_", var.stripe_secret_key_test))
    error_message = "Stripe test secret key must start with 'sk_test_'."
  }
}

variable "stripe_webhook_secret_test" {
  description = "Stripe webhook endpoint secret for test environment"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^whsec_", var.stripe_webhook_secret_test))
    error_message = "Stripe webhook secret must start with 'whsec_'."
  }
}

# === STRIPE CONFIGURATION (Live Keys - Optional) ===
variable "stripe_publishable_key_live" {
  description = "Stripe publishable key for live environment"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition = var.stripe_publishable_key_live == "" || can(regex("^pk_live_", var.stripe_publishable_key_live))
    error_message = "Stripe live publishable key must start with 'pk_live_' or be empty."
  }
}

variable "stripe_secret_key_live" {
  description = "Stripe secret key for live environment"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition = var.stripe_secret_key_live == "" || can(regex("^sk_live_", var.stripe_secret_key_live))
    error_message = "Stripe live secret key must start with 'sk_live_' or be empty."
  }
}

variable "stripe_webhook_secret_live" {
  description = "Stripe webhook endpoint secret for live environment"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition = var.stripe_webhook_secret_live == "" || can(regex("^whsec_", var.stripe_webhook_secret_live))
    error_message = "Stripe live webhook secret must start with 'whsec_' or be empty."
  }
}

# === DERIVED VALUES ===
locals {
  # Use appropriate Stripe keys based on environment
  stripe_publishable_key = var.environment == "prod" && var.stripe_publishable_key_live != "" ? var.stripe_publishable_key_live : var.stripe_publishable_key_test
  stripe_secret_key     = var.environment == "prod" && var.stripe_secret_key_live != "" ? var.stripe_secret_key_live : var.stripe_secret_key_test
  stripe_webhook_secret = var.environment == "prod" && var.stripe_webhook_secret_live != "" ? var.stripe_webhook_secret_live : var.stripe_webhook_secret_test
  
  # Common tags for resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "whisky-hikes"
  }
}

# === OUTPUT VALIDATION ===
# Diese Outputs helfen beim Debugging, enthalten aber keine sensitiven Daten
output "environment_summary" {
  description = "Summary of the environment configuration"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.region
    stripe_mode  = var.environment == "prod" && var.stripe_secret_key_live != "" ? "live" : "test"
  }
}

# Validation: Ensure required secrets are provided
resource "null_resource" "secrets_validation" {
  triggers = {
    # Diese Trigger stellen sicher, dass alle erforderlichen Secrets vorhanden sind
    stripe_publishable_key = length(local.stripe_publishable_key) > 20 ? "valid" : "invalid"
    stripe_secret_key     = length(local.stripe_secret_key) > 20 ? "valid" : "invalid"
    stripe_webhook_secret = length(local.stripe_webhook_secret) > 10 ? "valid" : "invalid"
  }
  
  lifecycle {
    precondition {
      condition     = length(local.stripe_publishable_key) > 20
      error_message = "Stripe publishable key is required and must be properly formatted."
    }
    
    precondition {
      condition     = length(local.stripe_secret_key) > 20
      error_message = "Stripe secret key is required and must be properly formatted."
    }
    
    precondition {
      condition     = length(local.stripe_webhook_secret) > 10
      error_message = "Stripe webhook secret is required and must be properly formatted."
    }
  }
}