#!/bin/bash

# load_env.sh - Lädt Environment Variables aus .env für Terraform
# Usage: source ./load_env.sh oder ./load_env.sh terraform [command]

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

echo -e "${BLUE}🔐 Whisky Hikes - Environment Loader${NC}"
echo "=================================================="

# Prüfe ob .env existiert
if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "${RED}❌ Error: .env file not found!${NC}"
    echo -e "${YELLOW}💡 Please create .env file:${NC}"
    echo "   cp .env.example .env"
    echo "   # Then edit .env with your actual secrets"
    exit 1
fi

# Lade .env (ohne leere Zeilen und Kommentare)
echo -e "${BLUE}📁 Loading environment from: ${ENV_FILE}${NC}"
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ $line =~ ^[[:space:]]*# ]] && continue
    [[ $line =~ ^[[:space:]]*$ ]] && continue
    
    # Export the variable
    if [[ $line =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"
        
        # Remove quotes if present
        var_value="${var_value#\"}"
        var_value="${var_value%\"}"
        var_value="${var_value#\'}"
        var_value="${var_value%\'}"
        
        export "$var_name=$var_value"
        echo -e "${GREEN}✅ Loaded: ${var_name}${NC}"
    fi
done < "$ENV_FILE"

# Validiere wichtige Variablen
echo ""
echo -e "${BLUE}🔍 Validating required secrets...${NC}"

required_vars=(
    "SUPABASE_ACCESS_TOKEN"
    "SUPABASE_ORGANIZATION_ID" 
    "SUPABASE_DATABASE_PASSWORD"
    "STRIPE_PUBLISHABLE_KEY_TEST"
    "STRIPE_SECRET_KEY_TEST"
    "STRIPE_WEBHOOK_SECRET_TEST"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        missing_vars+=("$var")
        echo -e "${RED}❌ Missing: $var${NC}"
    else
        # Show partial value for verification (security)
        value="${!var}"
        if [[ ${#value} -gt 10 ]]; then
            masked="${value:0:6}...${value: -4}"
        else
            masked="***"
        fi
        echo -e "${GREEN}✅ Found: $var = $masked${NC}"
    fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}❌ Missing required environment variables!${NC}"
    echo -e "${YELLOW}Please add the following to your .env file:${NC}"
    for var in "${missing_vars[@]}"; do
        echo "   $var=your-value-here"
    done
    exit 1
fi

# Environment summary
echo ""
echo -e "${BLUE}📊 Environment Summary:${NC}"
echo "   Project: ${PROJECT_NAME:-whisky-hikes}"
echo "   Environment: ${ENVIRONMENT:-dev}"
echo "   Region: ${SUPABASE_REGION:-eu-central-1}"
echo "   Stripe Mode: $(if [[ -n "$STRIPE_SECRET_KEY_LIVE" && "$ENVIRONMENT" == "prod" ]]; then echo "🔴 LIVE"; else echo "🟡 TEST"; fi)"

# Wenn Terraform-Befehl übergeben wurde, führe ihn aus
if [[ "$1" == "terraform" ]]; then
    shift
    echo ""
    echo -e "${BLUE}🚀 Running Terraform with loaded environment...${NC}"
    echo "Command: terraform $*"
    echo ""
    
    # Set Terraform variables from environment
    export TF_VAR_supabase_access_token="$SUPABASE_ACCESS_TOKEN"
    export TF_VAR_organization_id="$SUPABASE_ORGANIZATION_ID"
    export TF_VAR_database_password="$SUPABASE_DATABASE_PASSWORD"
    export TF_VAR_project_name="${PROJECT_NAME:-whisky-hikes}"
    export TF_VAR_environment="${ENVIRONMENT:-dev}"
    export TF_VAR_region="${SUPABASE_REGION:-eu-central-1}"
    export TF_VAR_stripe_publishable_key_test="$STRIPE_PUBLISHABLE_KEY_TEST"
    export TF_VAR_stripe_secret_key_test="$STRIPE_SECRET_KEY_TEST"  
    export TF_VAR_stripe_webhook_secret_test="$STRIPE_WEBHOOK_SECRET_TEST"
    
    # Optional live keys
    if [[ -n "$STRIPE_PUBLISHABLE_KEY_LIVE" ]]; then
        export TF_VAR_stripe_publishable_key_live="$STRIPE_PUBLISHABLE_KEY_LIVE"
    fi
    if [[ -n "$STRIPE_SECRET_KEY_LIVE" ]]; then
        export TF_VAR_stripe_secret_key_live="$STRIPE_SECRET_KEY_LIVE"
    fi
    if [[ -n "$STRIPE_WEBHOOK_SECRET_LIVE" ]]; then
        export TF_VAR_stripe_webhook_secret_live="$STRIPE_WEBHOOK_SECRET_LIVE"
    fi
    
    # Execute terraform command
    terraform "$@"
else
    echo ""
    echo -e "${GREEN}✅ Environment loaded successfully!${NC}"
    echo -e "${YELLOW}💡 Usage examples:${NC}"
    echo "   ./load_env.sh terraform init"
    echo "   ./load_env.sh terraform plan" 
    echo "   ./load_env.sh terraform apply"
    echo ""
    echo -e "${YELLOW}💡 Or source this script:${NC}"
    echo "   source ./load_env.sh"
    echo "   terraform plan"
fi