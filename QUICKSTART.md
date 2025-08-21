# 🚀 Whisky Hikes - Quick Start Guide

Schnelle Anleitung zum Einrichten des Supabase-Projekts von Grund auf.

## ⚡ 5-Minuten Setup

### 1. Prerequisites installieren

```bash
# macOS
brew install terraform supabase/tap/supabase node

# Oder folge der detaillierten Anleitung in DEPLOYMENT.md
```

### 2. Credentials besorgen

1. Gehe zu [supabase.com/dashboard](https://supabase.com/dashboard)
2. **Access Token**: Profile → Access Tokens → "Generate new token"
3. **Organization ID**: Settings → Organization → ID kopieren

### 3. Projekt einrichten

```bash
# Repository klonen
git clone <your-repo>
cd whisky_hikes

# .env erstellen
cp .env.example .env
# Fülle SUPABASE_ACCESS_TOKEN ein

# Terraform-Variablen erstellen
cd terraform-supabase
cp terraform.tfvars.example terraform.tfvars
# Fülle organization_id und database_password ein
```

### 4. Deployment mit einem Befehl

```bash
# Im terraform-supabase Verzeichnis
make full-setup
```

**Das wars! 🎉**

### 5. Flutter-App konfigurieren

```bash
# API-Keys ausgeben
make show-outputs

# Kopiere die Werte in deine .env:
# SUPABASE_URL=<project_url>  
# SUPABASE_ANON_KEY=<anon_key>
```

### 6. Testen

```bash
# API-Test
make test-api

# Flutter-App starten
flutter run
```

## 🔧 Häufige Befehle

```bash
# Komplette Umgebung zurücksetzen
make dev-reset

# Nur Schema aktualisieren
make schema

# Custom SQL ausführen  
make sql SQL="SELECT * FROM hikes;"

# Backup erstellen
make backup

# Hilfe anzeigen
make help
```

## 📋 Template-Dateien

### .env.example
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_ACCESS_TOKEN=your-access-token
```

### terraform.tfvars.example  
```hcl
organization_id = "your-org-id"
project_name = "whisky-hikes"
region = "us-east-1" 
database_password = "your-secure-password"
environment = "dev"
```

## 🆘 Probleme?

### CLI funktioniert nicht?
```bash
# Alternative: Management API verwenden
./complete_schema.sh
./create_policies.sh
```

### Passwort vergessen?
```bash
# Neues Projekt erstellen
terraform destroy
terraform apply
```

### Mehr Details?
Siehe [DEPLOYMENT.md](./DEPLOYMENT.md) für die vollständige Dokumentation.

## 🎯 Was du bekommst

Nach dem Setup hast du:

- ✅ Vollständiges Supabase-Projekt
- ✅ Alle Tabellen (profiles, hikes, waypoints, etc.)
- ✅ Row Level Security (RLS) Policies  
- ✅ API-Keys für Flutter
- ✅ Beispieldaten zum Testen
- ✅ Infrastructure-as-Code mit Terraform

**Deine Flutter-App ist sofort einsatzbereit! 🍺🥾**