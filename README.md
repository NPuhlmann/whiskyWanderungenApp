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

- **Flutter SDK**: Version 3.27.0 oder höher
- **Dart SDK**: Version 3.9.0 oder höher
- **Android Studio** oder **VS Code** mit Flutter-Plugin
- **Git**
- **Terraform** (für Supabase-Deployment)

### Installation

1. **Repository klonen**
   ```bash
   git clone <repository-url>
   cd whisky_hikes
   ```

2. **Flutter-Dependencies installieren**
   ```bash
   flutter pub get
   ```

3. **Code generieren**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **App starten**
   ```bash
   flutter run
   ```

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

Erstelle eine `.env` Datei im Hauptverzeichnis:

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

### Tests ausführen

```bash
# Alle Tests
flutter test

# Nur Unit Tests
flutter test test/domain/

# Nur UI Tests
flutter test test/UI/

# Mit Coverage
flutter test --coverage
```

### Test-Struktur

- **Unit Tests**: `test/domain/` und `test/data/`
- **Widget Tests**: `test/UI/`
- **Integration Tests**: `test/integration/`
- **Mocks**: `test/mocks/`

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

### Automatische Tests

Bei jedem Push auf `main` oder `develop`:
- ✅ Flutter Tests (Unit, Widget, Integration)
- ✅ Code-Analyse und Formatierung
- ✅ Security Scans mit Trivy
- ✅ Multi-Platform Builds (Android, iOS, Web)
- ✅ Dependency-Checks

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
