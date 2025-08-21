#!/bin/bash

# Whisky Hikes Infrastructure Validation Script
# Überprüft die Terraform-Konfiguration und Supabase-Setup

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Terraform Validierung
validate_terraform() {
    log_info "Validiere Terraform-Konfiguration..."
    
    # Terraform Format Check
    if terraform fmt -check=true; then
        log_success "Terraform-Format ist korrekt"
    else
        log_warning "Terraform-Format kann verbessert werden"
        log_info "Führe 'terraform fmt' aus, um zu formatieren"
    fi
    
    # Terraform Validation
    if terraform validate; then
        log_success "Terraform-Konfiguration ist gültig"
    else
        log_error "Terraform-Konfiguration enthält Fehler"
        exit 1
    fi
    
    # Terraform Plan (dry-run)
    log_info "Erstelle Terraform Plan zur Validierung..."
    if terraform plan -out=validation.tfplan > /dev/null 2>&1; then
        log_success "Terraform Plan erfolgreich erstellt"
        rm -f validation.tfplan
    else
        log_error "Terraform Plan fehlgeschlagen"
        exit 1
    fi
}

# SQL Validierung
validate_sql() {
    log_info "Validiere SQL-Dateien..."
    
    local sql_files=("sql/01_create_tables.sql" "sql/02_create_functions.sql" "sql/03_create_policies.sql" "sql/04_insert_sample_data.sql")
    
    for file in "${sql_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "✓ $file gefunden"
            
            # Basic SQL syntax check (if sqlfluff is available)
            if command -v sqlfluff &> /dev/null; then
                if sqlfluff lint "$file" &> /dev/null; then
                    log_success "  ✓ SQL-Syntax korrekt"
                else
                    log_warning "  ⚠ SQL-Syntax-Warnungen in $file"
                fi
            fi
        else
            log_error "✗ $file nicht gefunden"
            exit 1
        fi
    done
}

# Abhängigkeiten prüfen
check_dependencies() {
    log_info "Prüfe erforderliche Abhängigkeiten..."
    
    local deps=("terraform" "supabase")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            log_success "✓ $dep installiert"
        else
            log_error "✗ $dep nicht installiert"
            missing_deps+=("$dep")
        fi
    done
    
    # Optional dependencies
    local optional_deps=("jq" "sqlfluff")
    for dep in "${optional_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            log_success "✓ $dep installiert (optional)"
        else
            log_warning "○ $dep nicht installiert (optional)"
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Fehlende Abhängigkeiten: ${missing_deps[*]}"
        exit 1
    fi
}

# Konfigurationsdateien prüfen
check_configuration() {
    log_info "Prüfe Konfigurationsdateien..."
    
    # terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        log_success "✓ terraform.tfvars gefunden"
        
        # Check for required variables
        local required_vars=("organization_id" "database_password")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var" terraform.tfvars; then
                log_success "  ✓ $var konfiguriert"
            else
                log_error "  ✗ $var fehlt in terraform.tfvars"
                exit 1
            fi
        done
    else
        log_error "✗ terraform.tfvars nicht gefunden"
        log_info "Kopiere terraform.tfvars.example zu terraform.tfvars"
        exit 1
    fi
    
    # Environment variables
    if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
        log_success "✓ SUPABASE_ACCESS_TOKEN gesetzt"
    else
        log_error "✗ SUPABASE_ACCESS_TOKEN nicht gesetzt"
        exit 1
    fi
}

# Supabase Connectivity Check
check_supabase_connectivity() {
    log_info "Prüfe Supabase-Verbindung..."
    
    # Check if we can authenticate with Supabase
    if supabase projects list &> /dev/null; then
        log_success "✓ Supabase-Authentifizierung erfolgreich"
        
        # List available organizations
        log_info "Verfügbare Organisationen:"
        supabase orgs list 2>/dev/null || log_warning "Keine Organisationen gefunden oder keine Berechtigung"
        
    else
        log_error "✗ Supabase-Authentifizierung fehlgeschlagen"
        log_info "Überprüfe deinen SUPABASE_ACCESS_TOKEN"
        exit 1
    fi
}

# Security Check
security_check() {
    log_info "Führe Sicherheitsprüfung durch..."
    
    # Check for hardcoded secrets
    if grep -r "sk-.*" . --exclude-dir=.git --exclude="*.sh" 2>/dev/null; then
        log_error "Mögliche hardcodierte API-Keys gefunden!"
        exit 1
    else
        log_success "✓ Keine hardcodierten Secrets gefunden"
    fi
    
    # Check file permissions
    if [ -f "terraform.tfvars" ]; then
        local perms=$(stat -f "%OLp" terraform.tfvars 2>/dev/null || stat -c "%a" terraform.tfvars 2>/dev/null)
        if [ "$perms" = "600" ] || [ "$perms" = "644" ]; then
            log_success "✓ terraform.tfvars hat sichere Berechtigungen"
        else
            log_warning "⚠ terraform.tfvars sollte restriktive Berechtigungen haben (600 oder 644)"
        fi
    fi
}

# Hauptfunktion
main() {
    log_info "Starte Whisky Hikes Infrastructure Validation..."
    echo ""
    
    check_dependencies
    echo ""
    
    check_configuration
    echo ""
    
    check_supabase_connectivity
    echo ""
    
    validate_sql
    echo ""
    
    validate_terraform
    echo ""
    
    security_check
    echo ""
    
    log_success "Alle Validierungen erfolgreich! ✅"
    log_info "Die Infrastruktur ist bereit für das Deployment."
}

# Skript ausführen
main "$@"