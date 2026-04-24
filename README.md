# 🥃 Whisky Hikes

Eine Flutter-basierte Mobile App für geführte Whisky-Wanderungen. Benutzer können vorgefertigte Wanderrouten kaufen und erhalten dazu ein professionelles Tasting-Set, das sie entweder abholen oder per Post geliefert bekommen. Während der Wanderung führt die App sie zu speziellen Wegpunkten, wo sie Whisky-Tastings mit detaillierten Erklärungen und Tasting Notes genießen können.

## 📱 App-Features

- **Wanderrouten-Shop**: Kaufe vorgefertigte Whisky-Wanderrouten
- **Tasting-Set-Management**: Abholung oder Lieferung der Whisky-Sets
- **Geführte Wanderungen**: Schritt-für-Schritt Navigation zu Tasting-Wegpunkten
- **Whisky-Erklärungen**: Detaillierte Informationen zu jedem Whisky
- **Tasting Notes**: Professionelle Bewertungen und Geschmacksnoten
- **Offline-Funktionalität**: Lokales Caching für bessere Performance
- **Mehrsprachigkeit**: Unterstützung für Deutsch und Englisch

## 🏗️ Projektstruktur

```
whisky_hikes/
├── lib/                    # Flutter App-Code
│   ├── config/            # Konfiguration und Routing
│   │   ├── dependencies.dart  # App-Abhängigkeiten
│   │   ├── l10n/             # Lokalisierung (Deutsch/Englisch)
│   │   └── routing/          # Navigation und Routen
│   ├── data/              # Datenebene
│   │   ├── repositories/   # Daten-Repositories
│   │   └── services/       # Backend-Services (Auth, Cache, API)
│   ├── domain/            # Geschäftslogik
│   │   └── models/        # Datenmodelle (Hike, Profile, etc.)
│   └── UI/                # Benutzeroberfläche
│       ├── auth/          # Login und Registrierung
│       ├── core/          # Gemeinsame UI-Komponenten
│       ├── home/          # Startseite und Übersicht
│       ├── hike_details/  # Wanderrouten-Details
│       ├── hike_map/      # Karten-Integration
│       ├── my_hikes/      # Meine Wanderrouten
│       └── profile/       # Benutzerprofil
├── terraform-supabase/    # Infrastructure as Code
├── test/                  # Test-Dateien
└── assets/                # Bilder, Icons und andere Assets
```

## 🚀 Development Setup

### Voraussetzungen

- **Flutter SDK**: `3.41.7` (Pin in `.github/workflows/*.yml` via `FLUTTER_VERSION`). Mindestanforderung: `>=3.35.1` (pubspec `environment.flutter`).
- **Dart SDK**: `3.11.5` (kommt mit Flutter 3.41.7). Mindestanforderung: `^3.9.0`.
- **Android Studio** oder **VS Code** mit Flutter-Plugin
- **Git**
- **Terraform** (nur für Supabase-Provisioning; für App-Dev nicht nötig)

### Ein-Befehl Bootstrap

Nach `git clone` reicht aus frischem Stand heraus:

```bash
cp .env.example .env \
  && flutter pub get \
  && dart run build_runner build --delete-conflicting-outputs \
  && flutter run
```

`.env` ist nötig, weil `pubspec.yaml` `.env` als Flutter-Asset registriert. Die mitgelieferte `.env.example` enthält nur öffentlich sichere Platzhalter — für echte Supabase-/Stripe-Keys siehe den `🔧 Umgebungsvariablen`-Abschnitt unten.

### Installationsschritte (manuell)

1. **Repository klonen**
   ```bash
   git clone <repository-url>
   cd whiskyWanderungenApp
   ```

2. **`.env` vorbereiten**
   ```bash
   cp .env.example .env
   # danach echte Werte in .env eintragen
   ```

3. **Flutter-Dependencies installieren**
   ```bash
   flutter pub get
   ```

4. **Code generieren (Freezed / JSON / Mocks)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **App starten**
   ```bash
   flutter run
   ```

### Häufig gebrauchte Kommandos

| Befehl | Zweck |
| --- | --- |
| `flutter pub get` | Dependencies installieren |
| `dart run build_runner build --delete-conflicting-outputs` | Codegen (Freezed, JSON, Mockito) einmalig ausführen |
| `dart run build_runner watch` | Codegen im Watch-Modus |
| `flutter analyze --no-fatal-infos` | Statische Analyse (CI-Modus — Warnings fatal, Infos informativ) |
| `flutter test test/widget_test.dart` | Adoption-Smoke-Test (CI-Gate) |
| `dart fix --apply` | Automatische Lint-Fixes anwenden |
| `flutter run` | App im Dev-Modus starten |
| `flutter build apk --debug` | Android Debug-APK bauen |
| `flutter build ios --debug --no-codesign` | iOS Debug-Build (ohne Signing) |

### Entwicklungsumgebung einrichten

#### VS Code (Empfohlen)
- Installiere die **Flutter** und **Dart** Extensions
- Aktiviere **Format on Save** für automatische Code-Formatierung
- Verwende **Flutter Inspector** für UI-Debugging

#### Android Studio
- Installiere das **Flutter Plugin**
- Konfiguriere einen Android-Emulator
- Verwende **Flutter Inspector** für UI-Debugging

## 🔧 Umgebungsvariablen

### .env Datei erstellen

Kopiere `.env.example` (im Projekt-Root eingecheckt) nach `.env` und fülle die Werte ein:

```bash
cp .env.example .env
```

`.env` ist in `.gitignore` und wird zusätzlich per `pubspec.yaml` (`flutter.assets: - .env`) als Flutter-Asset gebündelt. **Nur öffentliche / clientseitig sichere Werte hier ablegen** — alles, was im Bundle auftaucht, ist für Endnutzer lesbar. Operator-Geheimnisse (z. B. `SUPABASE_ACCESS_TOKEN`, Stripe Secret Keys) werden nur lokal fürs Provisioning / Terraform-Deployment gebraucht.

Erwartete Variablen (siehe `.env.example` für die vollständige Vorlage):

```bash
# Supabase Konfiguration
SUPABASE_URL=<deine-supabase-url>
SUPABASE_ANON_KEY=<dein-anon-key>
SUPABASE_ACCESS_TOKEN=<dein-access-token>

# Beispiel:
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_ACCESS_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Terraform-Variablen

Für das Supabase-Deployment erstelle `terraform-supabase/terraform.tfvars`:

```hcl
organization_id = "<deine-organization-id>"
project_name = "whisky-hikes"
region = "us-east-1"
database_password = "<starkes-passwort>"
environment = "dev"
```

### GitHub Secrets (für CI/CD)

Füge diese Secrets in deinem GitHub Repository hinzu:

#### Android
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

#### iOS
- `IOS_P12_BASE64`
- `IOS_P12_PASSWORD`
- `IOS_APP_STORE_CONNECT_API_KEY`
- `IOS_APP_STORE_CONNECT_ISSUER_ID`
- `IOS_APP_STORE_CONNECT_KEY_ID`

## 🗄️ Supabase Setup

### Bestehendes Supabase-Projekt wiederverwenden

Das Projekt enthält bereits die vollständige Supabase-Konfiguration. Vor dem Provisionieren eines neuen Projekts die folgenden Stellen prüfen:

- `terraform-supabase/main.tf`, `variables.tf`, `outputs.tf`, `vault_secrets.tf` — Infrastructure-as-Code für das Supabase-Projekt (Terraform).
- `terraform-supabase/supabase/config.toml` — lokale Supabase-CLI-Konfiguration.
- `terraform-supabase/supabase/migrations/20250821151237_initial_schema.sql` — initiales DB-Schema.
- `supabase_trigger_profile_creation.sql`, `migration_existing_users.sql` — zusätzliche SQL, die nach der Schema-Migration eingespielt wird.
- `lib/main.dart` — Laufzeit-Initialisierung via `Supabase.initialize(url: dotenv.env['SUPABASE_URL'], anonKey: dotenv.env['SUPABASE_ANON_KEY'])`.
- `lib/data/services/database/backend_api.dart` — zentraler Zugriffspunkt für Supabase-Aufrufe aus dem App-Code.

Wenn ein Supabase-Projekt bereits läuft, einfach `SUPABASE_URL` + `SUPABASE_ANON_KEY` aus dem Supabase-Dashboard (Settings → API) in die lokale `.env` eintragen — kein Re-Provisioning nötig. Für ein neues Projekt siehe den Abschnitt **Automatisches Deployment** unten.

### Automatisches Deployment

1. **Terraform initialisieren**
   ```bash
   cd terraform-supabase
   export SUPABASE_ACCESS_TOKEN="<dein-access-token>"
   terraform init
   ```

2. **Deployment ausführen**
   ```bash
   terraform plan
   terraform apply
   ```

3. **Datenbank-Schema erstellen**
   ```bash
   chmod +x complete_schema.sh
   ./complete_schema.sh
   ```

4. **RLS-Policies anwenden**
   ```bash
   chmod +x create_policies.sh
   ./create_policies.sh
   ```

### Manuelles Setup

Alternativ kannst du Supabase über das Dashboard einrichten:

1. Gehe zu [supabase.com](https://supabase.com)
2. Erstelle ein neues Projekt
3. Kopiere die API-Schlüssel in deine `.env` Datei
4. Erstelle die Tabellen manuell (siehe `terraform-supabase/sql/`)

## 🧪 Testing

### CI-Gate (aktueller Stand)

CI (`.github/workflows/ci.yml`) gatet aktuell auf zwei Signale:

- `flutter analyze --no-fatal-infos` (Warnings fatal, Infos nicht blockierend)
- `flutter test test/widget_test.dart` (Adoption-Smoke-Test gegen das Freezed-`Hike`-Modell)

Der breitere Testbaum (`test/UI/`, `test/data/`, `test/integration/`, `test/repositories/`, `test/services/`) ist gegen die aktuellen Produktions-Signaturen gedriftet — Mocks und Fixtures stammen aus früheren Refactors. Diese Bereiche sind aktuell aus `flutter analyze` ausgeschlossen (`analysis_options.yaml`) und werden im Follow-up-Burn-down-Ticket wieder reaktiviert.

### Tests lokal ausführen

```bash
# Nur der CI-Smoke-Test (garantiert grün)
flutter test test/widget_test.dart

# Gesamter Baum — bricht aktuell wegen Drift in mehreren Ordnern
flutter test

# Einzelner Ordner (sobald der Burn-down die Mocks reconciled hat)
flutter test test/domain/

# Mit Coverage
flutter test test/widget_test.dart --coverage
```

### Test-Struktur

- **Smoke / CI-Gate**: `test/widget_test.dart`
- **Unit Tests**: `test/domain/` und `test/data/` — *unter Burn-down, z. T. gedriftet*
- **Widget Tests**: `test/UI/` — *unter Burn-down*
- **Integration Tests**: `test/integration/` — *unter Burn-down*
- **Mocks**: `test/mocks/` — per `@GenerateMocks` neu generieren nach Signatur-Angleichung

## 📱 Build & Release

### Debug Builds

```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug

# Web
flutter build web
```

### Release Builds

#### Android

1. **Keystore erstellen**
   ```bash
   keytool -genkey -v -keystore whisky-hikes.keystore \
     -alias whisky-hikes -keyalg RSA -keysize 2048 \
     -validity 10000
   ```

2. **Release APK bauen**
   ```bash
   flutter build apk --release
   ```

3. **App Bundle für Play Store**
   ```bash
   flutter build appbundle --release
   ```

#### iOS

1. **Code Signing konfigurieren**
   - P12-Zertifikat in Keychain importieren
   - Provisioning Profile herunterladen

2. **Release IPA bauen**
   ```bash
   flutter build ios --release
   ```

3. **Über Xcode archivieren**
   - Product → Archive
   - Distribute App

### Automatisierte Releases

Die CI/CD Pipeline erstellt automatisch Release-Builds:

1. Gehe zu **GitHub Actions**
2. Wähle **Release Build** Workflow
3. Klicke **Run workflow**
4. Wähle den Branch aus (normalerweise `main`)

## 🔄 CI/CD Pipeline

### `.github/workflows/ci.yml`

Bei jedem Push/PR auf `main` bzw. PR auf `main`:

- `test` — `flutter analyze --no-fatal-infos` + `flutter test test/widget_test.dart` (Adoption-Smoke-Test).
- `security-scan` — Trivy FS-Scan + SARIF-Upload.
- `build-android` — `flutter build apk --debug` und `appbundle --debug` als Artifacts.
- `build-ios` — `flutter build ios --debug --no-codesign` auf `macos-latest`.
- `build-web` — **deaktiviert** (`if: false`), bis die Drift unter `lib/UI/web/**` im Burn-down-Ticket reconciled ist.
- `dependency-check` — `flutter pub outdated` + `flutter pub deps --style=tree`.
- `notify` — fasst den Gesamtstatus zusammen (`needs: test, build-android, build-ios, security-scan, dependency-check`).

Flutter-Version kommt aus dem `FLUTTER_VERSION` Env im jeweiligen Workflow (`3.41.7`).

### Release-Workflow

1. **Version in `pubspec.yaml` erhöhen**
2. **GitHub Release erstellen**
3. **Release-Pipeline läuft automatisch**
4. **Builds werden als Release Assets hochgeladen**

## 🚨 Troubleshooting

### Häufige Probleme

#### "Invalid API Key"
- Überprüfe deine `.env` Datei
- Stelle sicher, dass die App neu gestartet wurde

#### "Table doesn't exist"
- Führe das Supabase-Schema-Setup aus
- Überprüfe die Migration-Dateien

#### Build-Fehler
- Führe `flutter clean` aus
- Überprüfe die Flutter-Version
- Stelle sicher, dass alle Dependencies installiert sind

### Debug-Modi

```bash
# Flutter Doctor
flutter doctor -v

# Dependency Tree
flutter pub deps --style=tree

# Build Runner
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📚 Nützliche Befehle

### Entwicklung

```bash
# Hot Reload
r

# Hot Restart
R

# Quit
q

# Flutter Doctor
flutter doctor

# Dependencies aktualisieren
flutter pub upgrade
```

### Build & Deploy

```bash
# Clean Build
flutter clean && flutter pub get

# Generate Code
flutter packages pub run build_runner build

# Build für alle Plattformen
flutter build apk --release
flutter build ios --release
flutter build web
```

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. Committe deine Änderungen (`git commit -m 'Add amazing feature'`)
4. Push zum Branch (`git push origin feature/amazing-feature`)
5. Öffne einen Pull Request

### Code-Standards

- Verwende `flutter analyze` vor dem Commit
- Formatiere Code mit `dart format`
- Schreibe Tests für neue Features
- Folge den Flutter Style Guidelines

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) für Details.

## 🆘 Support

- **Issues**: Erstelle ein Issue auf GitHub
- **Dokumentation**: Siehe `DEPLOYMENT.md` für detaillierte Deployment-Anweisungen
- **CI/CD**: Siehe `CI_CD_SETUP.md` für Pipeline-Konfiguration

## 🙏 Danksagungen

- **Flutter Team** für das großartige Framework
- **Supabase** für die Backend-Infrastruktur
- **OpenStreetMap** für die Kartendaten
- Alle Contributors und Tester

---

**Viel Spaß beim Entwickeln und Whisky-Tasting! 🥃🥾**
