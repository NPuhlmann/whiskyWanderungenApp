# Whisky Hikes - Supabase Terraform Infrastructure

Dieses Terraform-Projekt verwaltet die komplette Supabase-Infrastruktur für die Whisky Hikes Flutter-App.

## 🏗️ Infrastruktur-Komponenten

### Datenbank-Tabellen
- **profiles**: Benutzerprofile (erweitert auth.users)
- **hikes**: Wanderungen mit Whisky-Destillerien
- **waypoints**: Wegpunkte entlang der Wanderungen
- **hikes_waypoints**: Many-to-Many Verknüpfung zwischen Wanderungen und Wegpunkten
- **purchased_hikes**: Gekaufte Wanderungen der Benutzer
- **hike_images**: Bilder für Wanderungen
- **user_waypoint_visits**: Tracking besuchter Wegpunkte

### Storage
- **avatars**: Bucket für Profilbilder der Benutzer

### Sicherheit
- Row Level Security (RLS) Policies für alle Tabellen
- Authentifizierung über Supabase Auth
- Sichere Storage-Policies

### Funktionen
- Automatische Profilerstellung für neue Benutzer
- Wanderungen kaufen
- Wegpunkte als besucht markieren
- Benutzerstatistiken abrufen

## 🚀 Installation und Setup

### Voraussetzungen

1. **Terraform** (Version >= 1.0)
   ```bash
   # macOS mit Homebrew
   brew install terraform
   
   # Oder von der offiziellen Website
   # https://www.terraform.io/downloads.html
   ```

2. **Supabase CLI** (erforderlich für Hybrid-Ansatz)
   ```bash
   # Mit npm
   npm install -g supabase
   
   # Mit Homebrew (macOS)
   brew install supabase/tap/supabase
   
   # Oder lade direkt von GitHub herunter
   # https://github.com/supabase/cli/releases
   ```

3. **Zusätzliche Tools** (optional aber empfohlen)
   ```bash
   # jq für JSON-Verarbeitung
   brew install jq
   
   # sqlfluff für SQL-Validierung
   pip install sqlfluff
   ```

4. **Supabase Account** und Access Token
   - Erstelle ein Konto auf [supabase.com](https://supabase.com)
   - Erstelle eine Organisation im Supabase Dashboard
   - Generiere einen Access Token unter: https://supabase.com/dashboard/account/tokens

### Konfiguration

1. **Klonen und Konfigurieren**
   ```bash
   cd terraform-supabase
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Variablen anpassen**
   Bearbeite `terraform.tfvars`:
   ```hcl
   organization_id = "deine-organization-id"
   region = "us-east-1"  # oder eine andere Region
   database_password = "dein-sicheres-passwort"
   ```

3. **Umgebungsvariablen setzen**
   ```bash
   export SUPABASE_ACCESS_TOKEN="dein-access-token"
   ```

### Deployment

#### Option 1: Automatisiertes Deployment (Empfohlen)

1. **Validierung (optional aber empfohlen)**
   ```bash
   cd terraform-supabase
   ./scripts/validate.sh
   ```

2. **Deployment ausführen**
   ```bash
   ./scripts/deploy.sh
   ```

#### Option 2: Manuelles Deployment

1. **Terraform initialisieren**
   ```bash
   terraform init
   ```

2. **Plan überprüfen**
   ```bash
   terraform plan
   ```

3. **Infrastruktur erstellen**
   ```bash
   terraform apply
   ```

4. **Supabase CLI Setup (falls nicht automatisch erfolgt)**
   ```bash
   # Projekt verlinken
   supabase link --project-ref <project-id>
   
   # Migrationen anwenden
   supabase db push
   
   # Beispieldaten laden (optional)
   supabase db seed
   ```

5. **Outputs anzeigen**
   ```bash
   terraform output
   ```

#### Hybrid-Ansatz Erklärung

Dieses Setup verwendet einen **Hybrid-Ansatz**:
- **Terraform** erstellt das Supabase-Projekt und die grundlegende Infrastruktur
- **Supabase CLI** handhabt Datenbank-Migrationen, Funktionen und Policies
- **Automatisierte Skripte** orchestrieren beide Tools für nahtlose Deployments

## 📊 Datenbank-Schema

### Haupttabellen

#### profiles
```sql
- id (UUID, PK) - Referenz auf auth.users
- first_name (TEXT)
- last_name (TEXT)
- date_of_birth (DATE)
- email (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### hikes
```sql
- id (SERIAL, PK)
- name (TEXT)
- length (DOUBLE PRECISION)
- steep (DOUBLE PRECISION)
- elevation (INTEGER)
- description (TEXT)
- price (DOUBLE PRECISION)
- difficulty (TEXT) - 'easy', 'mid', 'hard', 'very_hard'
- thumbnail_image_url (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### waypoints
```sql
- id (SERIAL, PK)
- name (TEXT)
- description (TEXT)
- latitude (DOUBLE PRECISION)
- longitude (DOUBLE PRECISION)
- images (TEXT[])
- is_visited (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

## 🔐 Sicherheitsrichtlinien

### Row Level Security (RLS)

Alle Tabellen haben RLS aktiviert mit spezifischen Policies:

- **profiles**: Benutzer können nur ihr eigenes Profil bearbeiten
- **hikes**: Alle authentifizierten Benutzer können lesen, nur Admins können verwalten
- **waypoints**: Alle authentifizierten Benutzer können lesen, nur Admins können verwalten
- **purchased_hikes**: Benutzer können nur ihre eigenen Käufe sehen und verwalten
- **user_waypoint_visits**: Benutzer können nur ihre eigenen Besuche verwalten

### Storage Policies

- Benutzer können nur ihre eigenen Profilbilder hochladen/bearbeiten
- Öffentliche Leserechte für Profilbilder (für App-Anzeige)

## 🛠️ Verwaltung

### Neue Wanderung hinzufügen

```sql
INSERT INTO public.hikes (name, length, steep, elevation, description, price, difficulty)
VALUES ('Neue Wanderung', 10.5, 0.15, 300, 'Beschreibung', 29.99, 'mid');
```

### Wegpunkt zu Wanderung hinzufügen

```sql
-- Zuerst Wegpunkt erstellen
INSERT INTO public.waypoints (name, description, latitude, longitude)
VALUES ('Neuer Wegpunkt', 'Beschreibung', 57.8231, -4.0333);

-- Dann Verknüpfung erstellen
INSERT INTO public.hikes_waypoints (hike_id, waypoint_id)
VALUES (1, (SELECT id FROM public.waypoints WHERE name = 'Neuer Wegpunkt'));
```

### Benutzer-Statistiken abrufen

```sql
SELECT * FROM public.get_user_stats();
```

## 🔄 Updates und Wartung

### Infrastruktur Updates

```bash
# Mit Deployment-Skript (empfohlen)
./scripts/deploy.sh

# Oder manuell
terraform plan
terraform apply
```

### Datenbank-Migrationen

Für Schema-Änderungen gibt es mehrere Optionen:

#### Option 1: Über SQL-Dateien (empfohlen für größere Änderungen)
1. Bearbeite die SQL-Dateien in `/sql`
2. Führe das Deployment-Skript aus: `./scripts/deploy.sh`

#### Option 2: Über Supabase CLI (empfohlen für kleinere Änderungen)
```bash
# Neue Migration erstellen
supabase migration new <migration_name>

# Migration bearbeiten und anwenden
supabase db push

# Schema-Unterschiede anzeigen
supabase db diff
```

#### Option 3: Über Supabase Dashboard
1. Änderungen direkt im Dashboard vornehmen
2. Schema mit CLI synchronisieren: `supabase db pull`

### Backup und Wiederherstellung

```bash
# Backup erstellen
supabase db dump --data-only > backup.sql

# Schema-Backup
supabase db dump --schema-only > schema.sql

# Vollständiges Backup
supabase db dump > full_backup.sql

# Wiederherstellen
supabase db reset
psql -h db.xxx.supabase.co -U postgres -d postgres < backup.sql
```

### Monitoring und Logs

```bash
# Projekt-Status überprüfen
supabase status

# Logs anzeigen
supabase logs

# Funktionen testen
supabase functions serve
```

## 🧪 Testing

### Lokale Entwicklung

```bash
# Supabase lokal starten
supabase start

# Tests ausführen
supabase test
```

### Integration Tests

```bash
# Mit echten Daten testen
terraform apply -var="environment=test"
```

## 📝 Troubleshooting

### Häufige Probleme

1. **Access Token Fehler**
   ```bash
   export SUPABASE_ACCESS_TOKEN="dein-token"
   ```

2. **Organisation ID nicht gefunden**
   - Überprüfe das Supabase Dashboard
   - Stelle sicher, dass du Mitglied der Organisation bist

3. **Datenbank-Verbindungsfehler**
   - Überprüfe das Datenbank-Passwort
   - Stelle sicher, dass die Region korrekt ist

### Logs und Debugging

```bash
# Terraform Debug-Modus
export TF_LOG=DEBUG
terraform apply

# Supabase Logs
supabase logs
```

## 📚 Weitere Ressourcen

- [Supabase Dokumentation](https://supabase.com/docs)
- [Terraform Dokumentation](https://www.terraform.io/docs)
- [PostgreSQL Dokumentation](https://www.postgresql.org/docs/)

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Mache deine Änderungen
4. Teste die Änderungen
5. Erstelle einen Pull Request

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. 