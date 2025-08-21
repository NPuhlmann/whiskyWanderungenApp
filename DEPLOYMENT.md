# Whisky Hikes - Supabase Deployment Dokumentation

Diese Dokumentation beschreibt, wie das Whisky Hikes Supabase-Projekt komplett neu aufgesetzt und verwaltet werden kann.

## 📋 Inhaltsverzeichnis

1. [Voraussetzungen](#voraussetzungen)
2. [Komplettes Neu-Deployment](#komplettes-neu-deployment)
3. [Datenbank-Schema Verwaltung](#datenbank-schema-verwaltung)
4. [RLS-Policies Verwaltung](#rls-policies-verwaltung)
5. [Migration-Workflow](#migration-workflow)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

## 🔧 Voraussetzungen

### Erforderliche Tools
- [Terraform](https://www.terraform.io/) >= 1.0
- [Supabase CLI](https://supabase.com/docs/guides/cli) >= 2.34
- [Node.js](https://nodejs.org/) >= 18 (für Flutter-Entwicklung)
- Git

### Installation der Tools

```bash
# Terraform (macOS)
brew install terraform

# Supabase CLI (macOS)  
brew install supabase/tap/supabase

# Node.js (macOS)
brew install node
```

### Erforderliche Credentials
1. **Supabase Access Token**: Aus dem [Supabase Dashboard](https://supabase.com/dashboard) → Profile → Access Tokens
2. **Supabase Organization ID**: Aus dem Dashboard → Settings → Organization
3. **Datenbank-Passwort**: Starkes Passwort für die PostgreSQL-Datenbank

## 🚀 Komplettes Neu-Deployment

### Schritt 1: Repository klonen und konfigurieren

```bash
git clone <repository-url>
cd whisky_hikes
```

### Schritt 2: Environment-Variablen einrichten

Erstelle eine `.env` Datei im Hauptverzeichnis:

```bash
# .env (wird von .gitignore ausgeschlossen)
SUPABASE_URL=<wird-nach-deployment-gesetzt>
SUPABASE_ANON_KEY=<wird-nach-deployment-gesetzt>  
SUPABASE_ACCESS_TOKEN=<dein-access-token>
```

### Schritt 3: Terraform-Variablen konfigurieren

Erstelle `terraform-supabase/terraform.tfvars`:

```hcl
# terraform.tfvars (wird von .gitignore ausgeschlossen)
organization_id = "<deine-organization-id>"
project_name = "whisky-hikes"
region = "us-east-1"
database_password = "<starkes-passwort>"
environment = "dev"
```

### Schritt 4: Terraform Deployment ausführen

```bash
cd terraform-supabase

# Terraform initialisieren
export SUPABASE_ACCESS_TOKEN="<dein-access-token>"
terraform init

# Deployment planen (Optional)
terraform plan

# Deployment ausführen
terraform apply
```

**Erwartete Ausgabe:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
project_id = "abcdefghijklmnop"
project_name = "whisky-hikes"
project_url = "https://abcdefghijklmnop.supabase.co"
anon_key = <sensitive>
service_role_key = <sensitive>
```

### Schritt 5: API-Schlüssel in .env aktualisieren

```bash
# API-Schlüssel aus Terraform-Output extrahieren
terraform output -raw project_url    # → SUPABASE_URL
terraform output -raw anon_key       # → SUPABASE_ANON_KEY
```

Aktualisiere die `.env` Datei im Hauptverzeichnis mit den neuen Werten.

### Schritt 6: Datenbank-Schema erstellen

#### Option A: Über Management API (Empfohlen bei CLI-Problemen)

```bash
# Tabellen erstellen
chmod +x complete_schema.sh
./complete_schema.sh

# RLS-Policies anwenden  
chmod +x create_policies.sh
./create_policies.sh

# Beispieldaten einfügen (Optional)
chmod +x insert_sample_data.sh
./insert_sample_data.sh
```

#### Option B: Über Supabase CLI (Standard-Weg)

```bash
# Mit Projekt verknüpfen
supabase link --project-ref=<project-id> --password=<db-password>

# Migrationen anwenden
supabase db push
```

### Schritt 7: Flutter-App konfigurieren

Nach einem erfolgreichen Deployment müssen folgende Werte in der Flutter-App aktualisiert werden:

#### A. Environment-Datei aktualisieren (.env)

```bash
# 1. Neue API-Werte aus Terraform extrahieren
cd terraform-supabase
PROJECT_URL=$(terraform output -raw project_url)
ANON_KEY=$(terraform output -raw anon_key)

# 2. .env Datei im Hauptverzeichnis aktualisieren
cd ..
echo "SUPABASE_URL=$PROJECT_URL" > .env
echo "SUPABASE_ANON_KEY=$ANON_KEY" >> .env
echo "SUPABASE_ACCESS_TOKEN=<dein-access-token>" >> .env
```

#### B. Flutter-Konfiguration überprüfen

Stelle sicher, dass diese Dateien die richtigen Environment-Variablen verwenden:

**`lib/config/dependencies.dart`** (falls vorhanden):
```dart
// Überprüfe dass dotenv korrekt geladen wird
import 'package:flutter_dotenv/flutter_dotenv.dart';

final supabaseUrl = dotenv.env['SUPABASE_URL']!;
final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
```

**`pubspec.yaml`**:
```yaml
# Stelle sicher, dass .env als Asset eingebunden ist
flutter:
  assets:
    - .env
```

#### C. App neustarten

```bash
# Flutter-App komplett neustarten
flutter clean
flutter pub get
flutter run
```

### Schritt 8: Deployment verifizieren

```bash
# API-Konnektivität testen
curl -X GET "<project-url>/rest/v1/hikes" \
  -H "apikey: <anon-key>" \
  -H "Content-Type: application/json"

# Erwartete Antwort: [] (leeres Array, da RLS aktiv ist)
```

## 🗄️ Datenbank-Schema Verwaltung

### Neue Tabelle hinzufügen

#### 1. Migration-Datei erstellen

```bash
cd terraform-supabase
supabase migration new add_new_table
```

#### 2. SQL in Migration-Datei schreiben

```sql
-- supabase/migrations/20240821120000_add_new_table.sql
CREATE TABLE IF NOT EXISTS public.new_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS aktivieren
ALTER TABLE public.new_table ENABLE ROW LEVEL SECURITY;

-- Policy erstellen
CREATE POLICY "Users can manage their own records" 
ON public.new_table 
FOR ALL 
USING (auth.uid() = user_id);
```

#### 3. Migration anwenden

```bash
# Über CLI (wenn verfügbar)
supabase db push

# Oder über Management API
./execute_migration.sh 20240821120000_add_new_table.sql
```

### Tabelle ändern

#### Spalte hinzufügen

```sql
-- supabase/migrations/20240821120001_add_column.sql
ALTER TABLE public.existing_table 
ADD COLUMN new_column TEXT DEFAULT '';
```

#### Spalte entfernen

```sql  
-- supabase/migrations/20240821120002_remove_column.sql
ALTER TABLE public.existing_table 
DROP COLUMN old_column;
```

### Index erstellen

```sql
-- supabase/migrations/20240821120003_add_indexes.sql
CREATE INDEX IF NOT EXISTS idx_table_column 
ON public.table_name(column_name);
```

## 🔐 RLS-Policies Verwaltung

### Neue Policy erstellen

```sql
-- Policy für SELECT-Operationen
CREATE POLICY "policy_name_select" 
ON public.table_name 
FOR SELECT 
USING (auth.uid() = user_id);

-- Policy für INSERT-Operationen  
CREATE POLICY "policy_name_insert"
ON public.table_name
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy für UPDATE-Operationen
CREATE POLICY "policy_name_update"
ON public.table_name  
FOR UPDATE
USING (auth.uid() = user_id);

-- Policy für DELETE-Operationen
CREATE POLICY "policy_name_delete"
ON public.table_name
FOR DELETE
USING (auth.uid() = user_id);
```

### Policy aktualisieren

```sql
-- Alte Policy löschen
DROP POLICY IF EXISTS "old_policy_name" ON public.table_name;

-- Neue Policy erstellen
CREATE POLICY "new_policy_name" 
ON public.table_name 
FOR SELECT 
USING (neue_bedingung);
```

### Häufige Policy-Patterns

#### Nur eigene Daten sehen

```sql
CREATE POLICY "users_own_data" 
ON public.table_name 
FOR ALL 
USING (auth.uid() = user_id);
```

#### Öffentlich lesbar, nur Owner kann bearbeiten

```sql
-- Alle können lesen
CREATE POLICY "public_read" 
ON public.table_name 
FOR SELECT 
USING (true);

-- Nur Owner kann ändern
CREATE POLICY "owner_write" 
ON public.table_name 
FOR UPDATE 
USING (auth.uid() = user_id);
```

#### Nur authentifizierte Benutzer

```sql
CREATE POLICY "authenticated_only" 
ON public.table_name 
FOR SELECT 
USING (auth.role() = 'authenticated');
```

## 🔄 Migration-Workflow

### Development → Staging → Production

#### 1. Lokale Entwicklung

```bash
# Neue Migration erstellen
supabase migration new feature_name

# SQL schreiben
vim supabase/migrations/20240821120000_feature_name.sql

# Lokal testen (mit lokalem Supabase)
supabase start
supabase db reset
```

#### 2. Staging Deployment

```bash
# Staging-Projekt verknüpfen
supabase link --project-ref=<staging-project-id>

# Migrationen anwenden
supabase db push
```

#### 3. Production Deployment

```bash
# Production-Projekt verknüpfen  
supabase link --project-ref=<prod-project-id>

# Migrationen anwenden
supabase db push
```

### Migration rückgängig machen

```sql
-- In neuer Migration-Datei
-- supabase/migrations/20240821120001_rollback_feature.sql

-- Tabelle löschen
DROP TABLE IF EXISTS public.new_table;

-- Spalte entfernen
ALTER TABLE public.existing_table DROP COLUMN new_column;

-- Policy löschen  
DROP POLICY IF EXISTS "policy_name" ON public.table_name;
```

## 📱 Flutter-App Konfiguration nach Neu-Deployment

### Übersicht: Was sich ändert

Bei einem kompletten Neu-Deployment ändern sich folgende Werte:

| Wert | Wo zu finden | Wo zu aktualisieren |
|------|-------------|-------------------|
| **Project URL** | `terraform output project_url` | `.env` → `SUPABASE_URL` |
| **Anonymous Key** | `terraform output anon_key` | `.env` → `SUPABASE_ANON_KEY` |
| **Service Role Key** | `terraform output service_role_key` | Backend/Admin-Tools |
| **Project ID** | `terraform output project_id` | CLI-Konfiguration |

### Schritt-für-Schritt Anleitung

#### 1. Neue Werte extrahieren

```bash
cd terraform-supabase

# Alle relevanten Werte auf einmal ausgeben
echo "=== NEUE SUPABASE KONFIGURATION ==="
echo ""
echo "SUPABASE_URL=$(terraform output -raw project_url)"
echo "SUPABASE_ANON_KEY=$(terraform output -raw anon_key)"
echo ""
echo "Zusätzliche Infos:"
echo "Project ID: $(terraform output -raw project_id)"
echo "Service Role Key: $(terraform output -raw service_role_key)"
```

#### 2. .env Datei automatisch aktualisieren

```bash
# Script zum automatischen Aktualisieren der .env
cat > update_env.sh << 'EOF'
#!/bin/bash
cd terraform-supabase

PROJECT_URL=$(terraform output -raw project_url)
ANON_KEY=$(terraform output -raw anon_key)
ACCESS_TOKEN=$(grep SUPABASE_ACCESS_TOKEN terraform.tfvars | cut -d'"' -f2)

cd ..

# Backup der alten .env
cp .env .env.backup

# Neue .env erstellen
echo "SUPABASE_URL=$PROJECT_URL" > .env
echo "SUPABASE_ANON_KEY=$ANON_KEY" >> .env
echo "SUPABASE_ACCESS_TOKEN=$ACCESS_TOKEN" >> .env

echo "✅ .env Datei aktualisiert!"
echo "📁 Backup gespeichert als .env.backup"
EOF

chmod +x update_env.sh && ./update_env.sh
```

#### 3. Flutter-App Dateien überprüfen

**A. Hauptinitialisierung (main.dart)**

Überprüfe, dass die .env-Datei korrekt geladen wird:

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env Datei laden
  await dotenv.load(fileName: ".env");
  
  runApp(MyApp());
}
```

**B. Supabase-Initialisierung**

Meist in `lib/config/dependencies.dart` oder ähnlich:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}
```

**C. pubspec.yaml prüfen**

```yaml
dependencies:
  flutter_dotenv: ^5.1.0  # Oder aktuelle Version
  supabase_flutter: ^2.6.0  # Oder aktuelle Version

flutter:
  assets:
    - .env  # WICHTIG: .env muss als Asset eingebunden sein
```

#### 4. Flutter-App komplett neustarten

```bash
# Vollständiger Neustart
flutter clean
flutter pub get

# Hot Restart reicht nicht - vollständig neu starten
flutter run --no-hot
```

#### 5. Verbindung testen

**A. In der App testen**

```dart
// Debug-Code zum Testen der Verbindung
void testSupabaseConnection() {
  final supabase = Supabase.instance.client;
  print('Supabase URL: ${supabase.supabaseUrl}');
  print('Connected: ${supabase.auth.currentUser != null}');
}
```

**B. Via API direkt testen**

```bash
# Test-Script erstellen
PROJECT_URL=$(cd terraform-supabase && terraform output -raw project_url)
ANON_KEY=$(cd terraform-supabase && terraform output -raw anon_key)

echo "Testing connection to: $PROJECT_URL"

curl -X GET "$PROJECT_URL/rest/v1/hikes" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"
```

### Häufige Probleme nach Neu-Deployment

#### Problem: "Invalid API Key"

**Ursache**: Alte API-Schlüssel in der App

**Lösung**:
```bash
# 1. Neue Schlüssel extrahieren
cd terraform-supabase && terraform output anon_key

# 2. .env aktualisieren  
# 3. App komplett neustarten (nicht nur Hot Reload)
flutter run --no-hot
```

#### Problem: "Table 'xyz' doesn't exist"

**Ursache**: Schema wurde nicht vollständig erstellt

**Lösung**:
```bash
cd terraform-supabase
make schema    # Oder: ./complete_schema.sh
make policies  # Oder: ./create_policies.sh
```

#### Problem: "Access denied" oder leere Daten

**Ursache**: RLS-Policies blockieren Zugriff

**Lösung**:
```bash
# 1. RLS-Status prüfen
./execute_sql.sh "SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';"

# 2. Policies überprüfen  
./execute_sql.sh "SELECT * FROM pg_policies WHERE tablename = 'hikes';"

# 3. Falls nötig, Policies neu anwenden
make policies
```

#### Problem: Flutter kann .env nicht laden

**Ursache**: .env nicht als Asset konfiguriert

**Lösung**:
```yaml
# pubspec.yaml
flutter:
  assets:
    - .env    # Diese Zeile muss vorhanden sein
```

### Checkliste nach Neu-Deployment

- [ ] Neue API-Schlüssel extrahiert (`terraform output`)
- [ ] `.env` Datei aktualisiert
- [ ] `pubspec.yaml` enthält .env als Asset
- [ ] Flutter-App mit `flutter clean` neugestartet
- [ ] API-Verbindung getestet
- [ ] Datenbank-Tabellen vorhanden
- [ ] RLS-Policies aktiv
- [ ] App-Funktionalität getestet (Login, Daten laden)

### Automatisierung

Füge dies zu deinem Makefile hinzu:

```makefile
update-flutter-config:
	@echo "📱 Updating Flutter app configuration..."
	@PROJECT_URL=$$(terraform output -raw project_url) && \
	 ANON_KEY=$$(terraform output -raw anon_key) && \
	 ACCESS_TOKEN=$$(grep SUPABASE_ACCESS_TOKEN terraform.tfvars | cut -d'"' -f2) && \
	 cd .. && \
	 cp .env .env.backup && \
	 echo "SUPABASE_URL=$$PROJECT_URL" > .env && \
	 echo "SUPABASE_ANON_KEY=$$ANON_KEY" >> .env && \
	 echo "SUPABASE_ACCESS_TOKEN=$$ACCESS_TOKEN" >> .env && \
	 echo "✅ Flutter configuration updated!"
	@echo "Next: flutter clean && flutter run --no-hot"
```

Verwendung:
```bash
make full-setup update-flutter-config
```

## 🔧 Troubleshooting

### CLI-Verbindungsprobleme

#### Problem: "password authentication failed"

```bash
# Lösung 1: Passwort explizit übergeben
supabase db push -p "<database-password>"

# Lösung 2: Projekt neu verknüpfen
supabase projects list
supabase link --project-ref=<project-id> --password=<password>
```

#### Problem: "connection refused"

```bash
# Projekt-Status prüfen
curl -X GET "https://api.supabase.com/v1/projects/<project-id>" \
  -H "Authorization: Bearer <access-token>"

# Einige Minuten warten (neue Projekte brauchen Zeit)
# Alternative: Management API verwenden
```

### Management API als Fallback

Wenn die CLI nicht funktioniert, verwende die Scripts:

```bash
# Tabellen erstellen
./complete_schema.sh

# Policies erstellen
./create_policies.sh  

# Custom SQL ausführen
./execute_sql.sh "CREATE TABLE test (id SERIAL PRIMARY KEY);"
```

### Häufige Fehler

#### "table does not exist"

```sql
-- Prüfe ob Tabelle existiert
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

#### "permission denied"

```sql
-- Prüfe RLS-Status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Prüfe Policies
SELECT * FROM pg_policies WHERE tablename = 'your_table';
```

## 📋 Best Practices

### Security

1. **Niemals Credentials in Git committen**
   - `.env` und `terraform.tfvars` sind in `.gitignore`
   - Access Token regelmäßig rotieren

2. **RLS immer aktivieren**
   ```sql
   ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY;
   ```

3. **Spezifische Policies für jede Operation**
   - Getrennte Policies für SELECT, INSERT, UPDATE, DELETE
   - Principle of Least Privilege befolgen

### Performance

1. **Indexe für Policy-Spalten**
   ```sql
   CREATE INDEX idx_table_user_id ON public.table_name(user_id);
   ```

2. **Policy-Performance testen**
   ```sql
   EXPLAIN ANALYZE SELECT * FROM table_name WHERE user_id = auth.uid();
   ```

### Wartung

1. **Migration-Dateien niemals ändern**
   - Nur neue Migrationen hinzufügen
   - Bei Fehlern: Rollback-Migration erstellen

2. **Backup vor großen Änderungen**
   ```bash
   supabase db dump -f backup.sql
   ```

3. **Monitoring einrichten**
   - Supabase Dashboard für Metriken nutzen
   - Alerts für kritische Tabellen

## 📞 Support

- **Supabase Dokumentation**: https://supabase.com/docs
- **CLI Referenz**: https://supabase.com/docs/reference/cli
- **Community**: https://github.com/supabase/supabase/discussions

## 📝 Changelog

- **2025-08-21**: Initiale Dokumentation
- Migration von CLI zu Management API für bessere Zuverlässigkeit
- Terraform-Integration für Infrastructure-as-Code