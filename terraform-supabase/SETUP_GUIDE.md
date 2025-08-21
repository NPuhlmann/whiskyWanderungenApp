# 🚀 Whisky Hikes Supabase Setup Guide (Free Tier)

Diese Anleitung führt Sie durch alle notwendigen Schritte, um Ihr Whisky Hikes Projekt im **kostenlosen Supabase Free Tier** zu deployieren.

## ✅ Bestätigung: Free Tier Konfiguration

✅ **Das Projekt ist explizit für den Free Tier konfiguriert**
- Plan: `free` (0€/Monat)
- Limits: 500MB Datenbank, 1GB Storage, 2 Millionen Edge Functions Invocations

## 📋 Benötigte Daten und Schritte

### Schritt 1: Supabase Account Setup

1. **Account erstellen** (falls noch nicht vorhanden)
   - Gehen Sie zu [supabase.com](https://supabase.com)
   - Registrieren Sie sich mit Email/GitHub/etc.

2. **Organisation erstellen**
   - Nach dem Login, klicken Sie auf "New Organization"
   - Geben Sie einen Organisationsnamen ein (z.B. "whisky-hikes-org")
   - Wählen Sie den **Free Plan**

3. **Organization ID ermitteln**
   ```
   1. Gehen Sie zu: https://supabase.com/dashboard
   2. Klicken Sie auf Ihre Organisation
   3. Die URL enthält die Organization ID: 
      https://supabase.com/dashboard/org/[ORGANIZATION-ID]
   4. Kopieren Sie diese ID
   ```

4. **Access Token generieren**
   ```
   1. Gehen Sie zu: https://supabase.com/dashboard/account/tokens
   2. Klicken Sie auf "Generate new token"
   3. Name: "whisky-hikes-terraform"
   4. Scopes: Alle auswählen (oder mindestens: projects:write)
   5. Kopieren Sie den Token (wird nur einmal angezeigt!)
   ```

### Schritt 2: Lokale Umgebung vorbereiten

1. **Abhängigkeiten installieren**
   ```bash
   # Terraform
   brew install terraform
   
   # Supabase CLI
   brew install supabase/tap/supabase
   # oder: npm install -g supabase
   
   # Optional aber empfohlen
   brew install jq
   ```

2. **Repository klonen und navigieren**
   ```bash
   cd whisky_hikes/terraform-supabase
   ```

3. **Konfigurationsdatei erstellen**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

4. **terraform.tfvars ausfüllen**
   ```hcl
   # Ihre Supabase Organization ID
   organization_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   
   # Region (wählen Sie eine in Ihrer Nähe)
   region = "eu-central-1"  # Frankfurt
   # oder: "us-east-1" (Virginia), "ap-southeast-1" (Singapur)
   
   # Sicheres Datenbank-Passwort (mindestens 8 Zeichen)
   database_password = "IhrSicheresPasswort123!"
   
   # Projektname (optional)
   project_name = "whisky-hikes"
   
   # Umgebung
   environment = "dev"
   ```

5. **Umgebungsvariablen setzen**
   ```bash
   # Access Token setzen
   export SUPABASE_ACCESS_TOKEN="sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   
   # Optional: In .bashrc/.zshrc hinzufügen für permanente Nutzung
   echo 'export SUPABASE_ACCESS_TOKEN="sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"' >> ~/.zshrc
   ```

### Schritt 3: Deployment ausführen

1. **Validierung (empfohlen)**
   ```bash
   # Prüft alle Voraussetzungen
   ./scripts/validate.sh
   ```

2. **Deployment starten**
   ```bash
   # Automatisiertes Deployment
   ./scripts/deploy.sh
   ```

   **Oder manuell:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Schritt 4: Erfolg überprüfen

Nach erfolgreichem Deployment erhalten Sie:

```bash
# Outputs anzeigen
terraform output

# Sollte ungefähr so aussehen:
project_id = "abcdefghijklmnopqrst"
project_url = "https://abcdefghijklmnopqrst.supabase.co"
anon_key = "eyJ...sehr_langer_key"
service_role_key = <sensitive>
```

## 🔧 Für Flutter App konfigurieren

Kopieren Sie die Werte in Ihre Flutter `.env` Datei:

```env
SUPABASE_URL=https://abcdefghijklmnopqrst.supabase.co
SUPABASE_ANON_KEY=eyJ...sehr_langer_key
```

## 💡 Free Tier Limits (wichtig zu wissen)

- **Datenbank**: 500MB PostgreSQL
- **Storage**: 1GB Dateien
- **Auth**: Unbegrenzte Benutzer
- **Edge Functions**: 500K Aufrufe/Monat
- **Realtime**: 200 gleichzeitige Verbindungen
- **API Requests**: 50K/Monat

## ❌ Häufige Probleme und Lösungen

### Problem: "Organization not found"
**Lösung**: 
- Prüfen Sie die Organization ID im Supabase Dashboard
- Stellen Sie sicher, dass Sie Mitglied der Organisation sind

### Problem: "Invalid access token"
**Lösung**:
- Generieren Sie einen neuen Token mit allen nötigen Scopes
- Prüfen Sie, dass die Umgebungsvariable korrekt gesetzt ist

### Problem: "Region not available"
**Lösung**:
- Verwenden Sie eine verfügbare Region: `us-east-1`, `eu-central-1`, `ap-southeast-1`

### Problem: "Database password too weak"
**Lösung**:
- Verwenden Sie mindestens 8 Zeichen mit Groß-/Kleinbuchstaben, Zahlen und Sonderzeichen

## 🧹 Projekt löschen (falls nötig)

```bash
# WARNUNG: Löscht alle Daten unwiderruflich!
./scripts/destroy.sh
```

## 📞 Support

Bei Problemen:
1. Prüfen Sie die Logs: `terraform apply` Output
2. Validieren Sie die Konfiguration: `./scripts/validate.sh`
3. Überprüfen Sie Supabase Dashboard auf Fehlermeldungen

---

**🎉 Nach erfolgreichem Setup haben Sie:**
- ✅ Kostenloses Supabase-Projekt
- ✅ Vollständiges Datenbankschema
- ✅ Benutzerauthentifizierung
- ✅ Storage für Bilder
- ✅ Beispieldaten zum Testen