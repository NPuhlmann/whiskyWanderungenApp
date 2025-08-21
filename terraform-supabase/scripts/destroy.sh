#!/bin/bash

# Whisky Hikes Supabase Destroy Script
# Dieses Skript löscht die Supabase-Infrastruktur sicher

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

# Sicherheitsabfrage
confirm_destroy() {
    echo ""
    log_error "ACHTUNG: Du bist dabei, die komplette Supabase-Infrastruktur zu löschen!"
    echo ""
    log_warning "Dies wird folgende Ressourcen unwiderruflich löschen:"
    echo "  - Supabase Projekt"
    echo "  - Alle Datenbank-Tabellen und Daten"
    echo "  - Storage Buckets und Dateien"
    echo "  - Alle Benutzer und Authentifizierungsdaten"
    echo ""
    log_error "Diese Aktion kann NICHT rückgängig gemacht werden!"
    echo ""
    
    read -p "Bist du sicher, dass du fortfahren möchtest? (Gebe 'DESTROY' ein, um zu bestätigen): " confirmation
    
    if [ "$confirmation" != "DESTROY" ]; then
        log_info "Löschung abgebrochen."
        exit 0
    fi
    
    echo ""
    log_warning "Letzte Warnung: Alle Daten gehen verloren!"
    read -p "Bist du wirklich sicher? (Gebe 'YES' ein, um zu bestätigen): " final_confirmation
    
    if [ "$final_confirmation" != "YES" ]; then
        log_info "Löschung abgebrochen."
        exit 0
    fi
}

# Prüfe Voraussetzungen
check_prerequisites() {
    log_info "Prüfe Voraussetzungen..."
    
    # Prüfe Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform ist nicht installiert."
        exit 1
    fi
    
    # Prüfe Supabase Access Token
    if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
        log_error "SUPABASE_ACCESS_TOKEN ist nicht gesetzt."
        exit 1
    fi
    
    # Prüfe terraform.tfvars
    if [ ! -f "terraform.tfvars" ]; then
        log_error "terraform.tfvars Datei nicht gefunden."
        exit 1
    fi
    
    log_success "Voraussetzungen erfüllt!"
}

# Terraform initialisieren
init_terraform() {
    log_info "Initialisiere Terraform..."
    terraform init
    log_success "Terraform initialisiert!"
}

# Terraform Destroy ausführen
run_destroy() {
    log_info "Führe Terraform Destroy aus..."
    terraform destroy -auto-approve
    log_success "Infrastruktur gelöscht!"
}

# Cleanup
cleanup() {
    log_info "Räume auf..."
    
    # Lösche Terraform-Dateien
    rm -rf .terraform
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f tfplan
    
    log_success "Cleanup abgeschlossen!"
}

# Hauptfunktion
main() {
    log_info "Starte Whisky Hikes Supabase Destroy..."
    echo ""
    
    confirm_destroy
    check_prerequisites
    init_terraform
    run_destroy
    cleanup
    
    log_success "Infrastruktur erfolgreich gelöscht!"
    log_info "Du kannst jetzt ein neues Projekt erstellen oder das Repository löschen."
}

# Skript ausführen
main "$@" 