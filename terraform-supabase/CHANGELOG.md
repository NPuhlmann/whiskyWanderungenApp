# Changelog

Alle wichtigen Änderungen an diesem Terraform-Projekt werden in dieser Datei dokumentiert.

## [2.0.0] - 2024-XX-XX

### 🔄 BREAKING CHANGES
- **Hybrid-Ansatz implementiert**: Kombination aus Terraform und Supabase CLI
- **Provider aktualisiert**: Von `supabase-community/supabase` zu `supabase/supabase`
- **Neue Abhängigkeit**: Supabase CLI ist jetzt erforderlich

### ✨ Added
- **storage.tf**: Dedizierte Storage-Konfiguration mit automatisierter Bucket-Erstellung
- **Validation Script**: `scripts/validate.sh` für umfassende Pre-Deployment-Checks
- **Enhanced Deploy Script**: Verbesserte Validierung und Supabase CLI Integration
- **Migration System**: Automatische Erstellung von Supabase-Migration-Dateien
- **Remote State Support**: Vorbereitung für S3 Backend (kommentiert)

### 🛠️ Changed
- **main.tf**: Komplett überarbeitet für stabilen Provider und null_resource-Integration
- **database.tf**: Umstellung auf Supabase CLI Migration-System
- **deploy.sh**: Erweiterte Voraussetzungsprüfung und bessere Fehlerbehandlung
- **README.md**: Vollständig aktualisierte Dokumentation mit Hybrid-Ansatz

### 🐛 Fixed
- **Provider Compatibility**: Lösung für experimentelle Provider-Probleme
- **Resource Dependencies**: Korrekte Abhängigkeitsreihenfolge zwischen Terraform und Supabase CLI
- **SQL Execution**: Zuverlässige Ausführung von Schema-Setup über CLI

### 📚 Documentation
- **Deployment Optionen**: Dokumentation für automatisierte und manuelle Deployments
- **Migration Workflow**: Detaillierte Anweisungen für Schema-Updates
- **Troubleshooting**: Erweiterte Fehlerbehebung und Best Practices

## [1.0.0] - 2024-XX-XX

### ✨ Initial Release
- **Terraform Setup**: Grundlegende Terraform-Konfiguration für Supabase
- **SQL Schema**: Vollständiges Datenbankschema für Whisky Hikes App
- **RLS Policies**: Umfassende Row Level Security Implementierung
- **Sample Data**: Realistische Beispieldaten für Development und Testing
- **Basic Scripts**: Grundlegende Deploy- und Destroy-Skripte

### 🏗️ Infrastructure Components
- **Database Tables**: profiles, hikes, waypoints, purchased_hikes, etc.
- **Storage Buckets**: avatars bucket für Profilbilder
- **Functions**: Utility-Funktionen für User Management und Stats
- **Security**: RLS Policies für alle Tabellen

---

## Upgrade Guide

### Von 1.x zu 2.x

1. **Supabase CLI installieren**:
   ```bash
   npm install -g supabase
   # oder
   brew install supabase/tap/supabase
   ```

2. **Umgebungsvariablen prüfen**:
   ```bash
   export SUPABASE_ACCESS_TOKEN="your-token"
   ```

3. **Validierung ausführen**:
   ```bash
   ./scripts/validate.sh
   ```

4. **Deployment aktualisieren**:
   ```bash
   terraform init -upgrade
   ./scripts/deploy.sh
   ```

### Wichtige Änderungen beachten

- ⚠️ **Provider-Änderung**: Stellen Sie sicher, dass der neue Provider verwendet wird
- ⚠️ **CLI-Abhängigkeit**: Supabase CLI ist jetzt erforderlich für Deployments
- ✅ **Verbesserte Stabilität**: Der neue Ansatz ist robuster und produktionstauglich
- ✅ **Bessere DX**: Erweiterte Validierung und Fehlerbehandlung

## Versionierung

Dieses Projekt folgt [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking Changes, die manuelle Migration erfordern
- **MINOR**: Neue Features, rückwärts kompatibel
- **PATCH**: Bug Fixes und kleine Verbesserungen