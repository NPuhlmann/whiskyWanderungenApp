#!/bin/bash

# Whisky Hikes Supabase Deployment Script
# Dieses Skript automatisiert die Bereitstellung der Supabase-Infrastruktur

set -e  # Exit on any error

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

# Prüfe Voraussetzungen
check_prerequisites() {
    log_info "Prüfe Voraussetzungen..."
    
    # Prüfe Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform ist nicht installiert. Bitte installiere Terraform zuerst."
        exit 1
    fi
    
    # Prüfe Supabase CLI
    if ! command -v supabase &> /dev/null; then
        log_error "Supabase CLI ist nicht installiert."
        log_info "Bitte installiere die Supabase CLI:"
        log_info "npm install -g supabase"
        log_info "oder: brew install supabase/tap/supabase"
        exit 1
    fi
    
    # Prüfe jq (für JSON parsing)
    if ! command -v jq &> /dev/null; then
        log_warning "jq ist nicht installiert (empfohlen für JSON parsing)"
        log_info "brew install jq"
    else
        # Prüfe Terraform Version
        TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
        log_info "Terraform Version: $TF_VERSION"
    fi
    
    # Prüfe Supabase CLI Version
    SUPABASE_VERSION=$(supabase --version)
    log_info "Supabase CLI Version: $SUPABASE_VERSION"
    
    # Prüfe Supabase Access Token
    if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
        log_error "SUPABASE_ACCESS_TOKEN ist nicht gesetzt."
        log_info "Bitte setze die Umgebungsvariable:"
        log_info "export SUPABASE_ACCESS_TOKEN='dein-access-token'"
        log_info "Token erhältlich unter: https://supabase.com/dashboard/account/tokens"
        exit 1
    fi
    
    # Prüfe terraform.tfvars
    if [ ! -f "terraform.tfvars" ]; then
        log_error "terraform.tfvars Datei nicht gefunden."
        log_info "Bitte kopiere terraform.tfvars.example zu terraform.tfvars und passe die Werte an."
        exit 1
    fi
    
    # Prüfe ob wir im richtigen Verzeichnis sind
    if [ ! -f "main.tf" ]; then
        log_error "main.tf nicht gefunden. Bitte führe das Skript im terraform-supabase Verzeichnis aus."
        exit 1
    fi
    
    log_success "Alle Voraussetzungen erfüllt!"
}

# Terraform initialisieren
init_terraform() {
    log_info "Initialisiere Terraform..."
    terraform init
    log_success "Terraform initialisiert!"
}

# Terraform Plan ausführen
run_plan() {
    log_info "Führe Terraform Plan aus..."
    terraform plan -out=tfplan
    log_success "Plan erstellt!"
}

# Terraform Apply ausführen
run_apply() {
    log_info "Führe Terraform Apply aus..."
    terraform apply tfplan
    log_success "Infrastruktur bereitgestellt!"
}

# Outputs anzeigen und finale Schritte
show_outputs() {
    log_info "Projekt-Informationen:"
    echo ""
    terraform output
    echo ""
    
    # Supabase Status prüfen
    log_info "Überprüfe Supabase-Projektstatus..."
    
    # Check if supabase is linked and working
    if supabase status &> /dev/null; then
        log_success "Supabase-Projekt ist bereit!"
        
        # Show some useful info
        echo ""
        log_info "Datenbank-Status:"
        supabase db diff --use-migra || log_warning "Keine Schema-Unterschiede gefunden (normal bei Erstinstallation)"
        
        echo ""
        log_info "Storage-Status:"
        supabase storage ls || log_warning "Storage könnte noch nicht vollständig konfiguriert sein"
        
    else
        log_warning "Supabase-Projekt benötigt möglicherweise zusätzliche Konfiguration"
    fi
    
    echo ""
    log_info "Nächste Schritte:"
    echo "1. Kopiere die Projekt-URL und API-Keys in deine Flutter .env Datei:"
    echo "   SUPABASE_URL=$(terraform output -raw project_url 2>/dev/null || echo 'siehe terraform output')"
    echo "   SUPABASE_ANON_KEY=$(terraform output -raw anon_key 2>/dev/null || echo 'siehe terraform output')"
    echo ""
    echo "2. Teste die Verbindung in deiner Flutter-App"
    echo "3. Überprüfe die Datenbank-Tabellen im Supabase Dashboard"
    echo "4. Optional: Führe 'supabase db seed' aus, um Beispieldaten zu laden"
    echo ""
    log_success "Deployment abgeschlossen! 🎉"
}

# Cleanup
cleanup() {
    log_info "Räume auf..."
    rm -f tfplan
    log_success "Cleanup abgeschlossen!"
}

# Hauptfunktion
main() {
    log_info "Starte Whisky Hikes Supabase Deployment..."
    echo ""
    
    check_prerequisites
    init_terraform
    run_plan
    
    echo ""
    log_warning "Möchtest du die Infrastruktur jetzt bereitstellen? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        run_apply
        show_outputs
    else
        log_info "Deployment abgebrochen."
    fi
    
    cleanup
    log_success "Deployment-Skript abgeschlossen!"
}

# Skript ausführen
main "$@" 