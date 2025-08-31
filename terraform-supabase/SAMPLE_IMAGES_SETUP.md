# Sample Images Setup für Whisky Hikes

Dieses Dokument beschreibt, wie die Sample Images aus dem `sample_images/` Verzeichnis in den Supabase Storage hochgeladen und mit den Beispielwanderungen verknüpft werden.

## Übersicht

Das Setup lädt automatisch alle JPEG-Bilder aus dem `sample_images/` Verzeichnis in den Supabase Storage hoch und verknüpft sie mit den 8 Beispielwanderungen. Jede Wanderung erhält 3-4 Bilder, die zufällig zugeordnet werden.

## Voraussetzungen

1. **Supabase Projekt** muss bereits erstellt sein
2. **Umgebungsvariablen** müssen gesetzt sein:
   - `SUPABASE_ACCESS_TOKEN`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `SUPABASE_URL` (wird automatisch generiert)

## Automatisches Setup über Terraform

Das Setup läuft automatisch beim Ausführen von `terraform apply`:

```bash
cd terraform-supabase
terraform apply
```

### Ablauf der Terraform-Ausführung:

1. **Storage Buckets erstellen** (`00_create_storage.sql`)
   - Erstellt `hike-images` Bucket für Wanderungsbilder
   - Erstellt `avatars` Bucket für Profilbilder

2. **Storage Policies konfigurieren** (`09_storage_policies.sql`)
   - Authentifizierte Benutzer können alle Bilder anzeigen
   - Nur Service Role kann Bilder hochladen/verwalten

3. **Sample Images hochladen** (`upload_sample_images.sh`)
   - Lädt alle JPEG-Bilder aus `sample_images/` hoch
   - Verteilt sie zufällig auf die 8 Wanderungen
   - Jede Wanderung erhält 3-4 Bilder

4. **Datenbank aktualisieren** (`10_update_hike_images.sql`)
   - Aktualisiert `hike_images` Tabelle
   - Setzt Thumbnail-URLs der Wanderungen
   - Verknüpft Bilder mit Wanderungen

## Manuelles Setup

Falls Sie das Setup manuell ausführen möchten:

### 1. Storage Buckets erstellen

```bash
# Führe das SQL-Skript aus
./execute_sql.sh "$(cat sql/00_create_storage.sql)"
```

### 2. Storage Policies konfigurieren

```bash
# Führe das SQL-Skript aus
./execute_sql.sh "$(cat sql/09_storage_policies.sql)"
```

### 3. Sample Images hochladen

```bash
# Setze Umgebungsvariablen
export SUPABASE_URL="https://your-project-ref.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Führe das Upload-Skript aus
./upload_sample_images.sh
```

### 4. Datenbank aktualisieren

```bash
# Führe das SQL-Skript aus
./execute_sql.sh "$(cat sql/10_update_hike_images.sql)"
```

## Verzeichnisstruktur

```
terraform-supabase/
├── sample_images/                    # Sample Images (10 JPEG-Dateien)
├── sql/
│   ├── 00_create_storage.sql        # Storage Buckets erstellen
│   ├── 09_storage_policies.sql      # Storage Policies konfigurieren
│   └── 10_update_hike_images.sql    # Bilder mit Wanderungen verknüpfen
├── upload_sample_images.sh           # Upload-Skript
└── main.tf                          # Terraform-Konfiguration
```

## Verfügbare Sample Images

Das `sample_images/` Verzeichnis enthält 10 hochauflösende JPEG-Bilder:

- `Gemini_Generated_Image_yaq3ziyaq3ziyaq3.jpg` (2.4MB)
- `Gemini_Generated_Image_ex7ftxex7ftxex7f.jpg` (2.6MB)
- `Gemini_Generated_Image_r5m0bhr5m0bhr5m0.jpg` (1.9MB)
- `Gemini_Generated_Image_9iyguy9iyguy9iyg.jpg` (2.3MB)
- `Gemini_Generated_Image_phnbd9phnbd9phnb.jpg` (3.4MB)
- `Gemini_Generated_Image_6ljw7t6ljw7t6ljw.jpg` (2.5MB)
- `Gemini_Generated_Image_6up7hw6up7hw6up7.jpg` (2.8MB)
- `Gemini_Generated_Image_x83xx5x83xx5x83x.jpg` (2.5MB)
- `Gemini_Generated_Image_w671avw671avw671.jpg` (1.5MB)
- `Gemini_Generated_Image_fkvh8rfkvh8rfkvh.jpg` (1.9MB)

## Beispielwanderungen

Die Bilder werden mit folgenden 8 Wanderungen verknüpft:

1. **Whisky Trail Highlands** - 3-4 Bilder
2. **Speyside Whisky Experience** - 3-4 Bilder
3. **Islay Coastal Adventure** - 3-4 Bilder
4. **Lowlands Whisky Discovery** - 3-4 Bilder
5. **Campbeltown Heritage Trail** - 3-4 Bilder
6. **Glenfiddich Explorer** - 3-4 Bilder
7. **Talisker Skye Journey** - 3-4 Bilder
8. **Aberlour Riverside Walk** - 3-4 Bilder

## Storage-Zugriff

### Für authentifizierte Benutzer:
- ✅ Alle Bilder anzeigen
- ❌ Bilder hochladen (nur Service Role)
- ❌ Bilder löschen (nur Service Role)

### Für Service Role:
- ✅ Alle Bilder anzeigen
- ✅ Bilder hochladen
- ✅ Bilder aktualisieren
- ✅ Bilder löschen

## Fehlerbehebung

### Häufige Probleme:

1. **"Permission denied" beim Upload**
   - Prüfe `SUPABASE_SERVICE_ROLE_KEY`
   - Stelle sicher, dass Storage Policies korrekt gesetzt sind

2. **"Bucket not found"**
   - Führe zuerst `00_create_storage.sql` aus
   - Prüfe, ob der `hike-images` Bucket existiert

3. **"Authentication failed"**
   - Prüfe `SUPABASE_ACCESS_TOKEN`
   - Stelle sicher, dass der Token gültig ist

### Logs prüfen:

```bash
# Terraform Logs
terraform apply -var-file="terraform.tfvars"

# Manuelle SQL-Ausführung
./execute_sql.sh "$(cat sql/10_update_hike_images.sql)"
```

## Nächste Schritte

Nach dem erfolgreichen Setup:

1. **Flutter App testen** - Bilder sollten in der App angezeigt werden
2. **Storage Policies prüfen** - Authentifizierte Benutzer sollten Bilder sehen können
3. **Performance optimieren** - Bilder können bei Bedarf komprimiert werden

## Sicherheitshinweise

- **Service Role Key** ist hochsensibel - niemals committen
- **Storage Policies** sind restriktiv konfiguriert
- **Authentifizierung** ist für alle Bildzugriffe erforderlich
- **Audit-Logs** werden für alle Storage-Operationen erstellt
