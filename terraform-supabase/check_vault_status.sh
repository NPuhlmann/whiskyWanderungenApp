#!/bin/bash

# check_vault_status.sh - Überprüft den Status des Supabase Vault
# Called by Terraform external data source

set -e

# Read input from Terraform
eval "$(jq -r '@sh "PROJECT_ID=\(.project_id) ACCESS_TOKEN=\(.access_token)"')"

# Check if required variables are set
if [[ -z "$PROJECT_ID" || -z "$ACCESS_TOKEN" ]]; then
    echo '{"error": "Missing required parameters"}' >&2
    exit 1
fi

# Function to make authenticated request to Supabase
make_supabase_request() {
    local sql_query="$1"
    local url="https://${PROJECT_ID}.supabase.co/rest/v1/rpc/test_vault_secrets"
    
    curl -s \
        -X POST \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -H "Prefer: return=representation" \
        -d "{}" \
        "$url" 2>/dev/null || echo "null"
}

# Test vault connectivity
echo "🔍 Checking Vault status..." >&2

# Try to call the test function
vault_test_result=$(make_supabase_request "test_vault_secrets")

if [[ "$vault_test_result" == "null" || "$vault_test_result" == "" ]]; then
    # Fallback: try direct SQL execution if available
    if [[ -f "$(dirname "$0")/execute_sql.sh" ]]; then
        export SUPABASE_ACCESS_TOKEN="$ACCESS_TOKEN"
        export PROJECT_ID="$PROJECT_ID"
        
        vault_test_result=$($(dirname "$0")/execute_sql.sh "SELECT test_vault_secrets() AS result;" 2>/dev/null | tail -n1 || echo "null")
    fi
fi

# Parse result or provide default
if [[ "$vault_test_result" != "null" && "$vault_test_result" != "" ]]; then
    # Extract relevant information from the result
    vault_available=$(echo "$vault_test_result" | jq -r '.vault_available // false' 2>/dev/null || echo "false")
    test_secrets_count=$(echo "$vault_test_result" | jq -r '.test_secrets_count // 0' 2>/dev/null || echo "0")
    live_secrets_count=$(echo "$vault_test_result" | jq -r '.live_secrets_count // 0' 2>/dev/null || echo "0")
    test_ready=$(echo "$vault_test_result" | jq -r '.test_environment_ready // false' 2>/dev/null || echo "false")
    live_ready=$(echo "$vault_test_result" | jq -r '.live_environment_ready // false' 2>/dev/null || echo "false")
else
    vault_available="false"
    test_secrets_count="0"
    live_secrets_count="0" 
    test_ready="false"
    live_ready="false"
fi

# Output result as JSON for Terraform
cat << EOF
{
    "vault_available": "$vault_available",
    "test_secrets_count": "$test_secrets_count",
    "live_secrets_count": "$live_secrets_count",
    "test_environment_ready": "$test_ready",
    "live_environment_ready": "$live_ready",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "project_id": "$PROJECT_ID"
}
EOF