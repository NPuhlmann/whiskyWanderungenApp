# 🔒 Sicherheitskonfiguration für Whisky Hikes Terraform

## ✅ Bereinigung abgeschlossen

Alle hardcodierten Secrets wurden aus dem Code entfernt. Das Projekt verwendet jetzt den **Supabase Vault** für sicheres Secret Management.

## 🚀 Nächste Schritte - MANUELL AUSFÜHREN

### 1. **Supabase Vault konfigurieren**

Gehe zu deinem Supabase Dashboard und füge folgende Secrets im Vault hinzu:

```sql
-- Im Supabase SQL Editor ausführen:
SELECT vault.create_secret('supabase_access_token', 'access_token', 'Supabase Management API Token');
SELECT vault.create_secret('project_id', 'project_id', 'Supabase Project ID');
SELECT vault.create_secret('organization_id', 'org_id', 'Supabase Organization ID');
SELECT vault.create_secret('database_password', 'db_password', 'Database Password');
```

### 2. **Lokale .env Datei konfigurieren**

Bearbeite die Datei `terraform-supabase/.env` und ersetze die Platzhalter:

```bash
# Supabase Configuration
SUPABASE_ACCESS_TOKEN=dein_access_token_aus_vault
PROJECT_ID=deine_project_id_aus_vault
ORGANIZATION_ID=deine_organization_id_aus_vault
DATABASE_PASSWORD=dein_database_password_aus_vault
```

### 3. **Terraform neu initialisieren**

```bash
cd terraform-supabase
terraform init
```

### 4. **Deployment testen**

```bash
# Test der Konfiguration
make plan

# Deployment ausführen
make apply
```

## 🔐 Sicherheitsfeatures

- ✅ **Keine hardcodierten Secrets mehr im Code**
- ✅ **Alle Skripte laden .env Datei automatisch**
- ✅ **Supabase Vault für zentrale Secrets-Verwaltung**
- ✅ **Terraform State-Dateien entfernt**
- ✅ **Alle .env* Dateien in .gitignore**

## 📋 Verwendung

### **Für Development:**
```bash
# .env Datei mit lokalen Werten
cp .env.example .env
# .env bearbeiten mit echten Werten
```

### **Für CI/CD:**
```bash
# Umgebungsvariablen setzen
export SUPABASE_ACCESS_TOKEN="..."
export PROJECT_ID="..."
# Skripte ausführen
```

### **Für Team-Entwicklung:**
```bash
# Nur .env.example committen
# Jeder Entwickler erstellt eigene .env
```

## 🚨 Wichtige Hinweise

1. **Niemals .env Datei committen**
2. **Alle Secrets regelmäßig rotieren**
3. **Vault-Zugriff auf Admins beschränken**
4. **Audit-Logs aktiviert halten**

## 🆘 Troubleshooting

### **Fehler: "SUPABASE_ACCESS_TOKEN not set"**
- Überprüfe .env Datei
- Stelle sicher, dass .env im richtigen Verzeichnis liegt
- Überprüfe Vault-Konfiguration

### **Fehler: "Project not found"**
- Überprüfe PROJECT_ID in .env
- Stelle sicher, dass der Token gültig ist
- Überprüfe Organization ID

## 📞 Support

Bei Problemen:
1. Überprüfe Supabase Dashboard → Logs
2. Teste API-Zugriff manuell
3. Überprüfe Vault-Berechtigungen
