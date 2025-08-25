# CI/CD Pipeline Setup für Whisky Hikes

## Übersicht

Diese CI/CD Pipeline automatisiert den Build- und Test-Prozess für die Whisky Hikes Flutter App. Sie läuft bei jedem Push auf den `main` oder `develop` Branch und ermöglicht manuelle Release-Builds.

## Workflows

### 1. CI Pipeline (`.github/workflows/ci.yml`)

**Trigger:** Push auf `main`/`develop`, Pull Requests

**Jobs:**
- **Tests**: Unit Tests, Widget Tests, Integration Tests
- **Security Scan**: Trivy Vulnerability Scanner
- **Builds**: Android, iOS, Web (Debug)
- **Dependency Check**: Veraltete Dependencies und Sicherheitslücken
- **Notifications**: Erfolgs-/Fehlermeldungen

### 2. Release Pipeline (`.github/workflows/release.yml`)

**Trigger:** Manuell, GitHub Release

**Jobs:**
- **Android Release**: APK und AAB mit Code Signing
- **iOS Release**: IPA mit Code Signing
- **Version Bump**: Automatische Versionserhöhung
- **GitHub Release**: Upload der Builds

## Setup Anleitung

### 1. GitHub Secrets konfigurieren

Gehe zu deinem GitHub Repository → Settings → Secrets and variables → Actions und füge folgende Secrets hinzu:

#### Android Secrets
```bash
ANDROID_KEYSTORE_BASE64          # Base64-kodierter Keystore
ANDROID_KEYSTORE_PASSWORD        # Keystore Passwort
ANDROID_KEY_ALIAS               # Key Alias
ANDROID_KEY_PASSWORD            # Key Passwort
```

#### iOS Secrets
```bash
IOS_P12_BASE64                  # Base64-kodierte P12-Datei
IOS_P12_PASSWORD                # P12 Passwort
IOS_APP_STORE_CONNECT_API_KEY   # App Store Connect API Key
IOS_APP_STORE_CONNECT_ISSUER_ID # App Store Connect Issuer ID
IOS_APP_STORE_CONNECT_KEY_ID    # App Store Connect Key ID
```

### 2. Android Keystore erstellen

```bash
# Keystore generieren
keytool -genkey -v -keystore whisky-hikes.keystore -alias whisky-hikes -keyalg RSA -keysize 2048 -validity 10000

# Base64 kodieren
base64 -i whisky-hikes.keystore | tr -d '\n' > keystore-base64.txt
```

### 3. iOS Code Signing Setup

1. **P12-Datei exportieren** aus Keychain Access
2. **Base64 kodieren**:
   ```bash
   base64 -i certificate.p12 | tr -d '\n' > p12-base64.txt
   ```
3. **Provisioning Profile** herunterladen und in Xcode importieren

### 4. iOS Export Options anpassen

Bearbeite `.github/workflows/ios-export-options.plist`:
- `YOUR_TEAM_ID` durch deine Team ID ersetzen
- `YOUR_PROVISIONING_PROFILE_NAME` durch den Profilnamen ersetzen
- Bundle ID anpassen falls nötig

## Verwendung

### Automatische CI
- Bei jedem Push auf `main`/`develop` läuft automatisch die CI-Pipeline
- Alle Tests werden ausgeführt
- Debug-Builds werden erstellt
- Security Scans werden durchgeführt

### Manueller Release
1. Gehe zu GitHub Actions
2. Wähle "Release Build" Workflow
3. Klicke "Run workflow"
4. Wähle Branch aus (normalerweise `main`)
5. Klicke "Run workflow"

### GitHub Release erstellen
1. Erstelle einen neuen Release auf GitHub
2. Tag mit `v1.0.0` (oder entsprechende Version)
3. Release-Pipeline läuft automatisch
4. Builds werden als Release Assets hochgeladen

## Build-Artefakte

### Android
- **APK**: `whisky-hikes-android-v1.0.0.apk`
- **AAB**: `whisky-hikes-android-v1.0.0.aab`

### iOS
- **IPA**: `whisky-hikes-ios-v1.0.0.ipa`

## Versionierung

Die Pipeline verwendet das Version-Schema aus `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Version + Build Number
```

Bei manuellen Releases wird der Build Number automatisch erhöht.

## Troubleshooting

### Häufige Probleme

1. **Code Signing Fehler**
   - Überprüfe GitHub Secrets
   - Stelle sicher, dass Keystore/Zeugnisse gültig sind

2. **Build Fehler**
   - Überprüfe Flutter Version
   - Stelle sicher, dass alle Dependencies installiert sind

3. **iOS Build Fehler**
   - Überprüfe Provisioning Profile
   - Stelle sicher, dass Team ID korrekt ist

### Logs überprüfen

- Gehe zu GitHub Actions
- Klicke auf den fehlgeschlagenen Workflow
- Überprüfe die Logs der fehlgeschlagenen Jobs

## Erweiterte Konfiguration

### Slack Notifications
Füge Slack Webhook URL zu GitHub Secrets hinzu:
```bash
SLACK_WEBHOOK_URL
```

### Custom Build Variants
Erstelle zusätzliche Workflows für:
- Beta Builds
- Staging Builds
- Feature Branch Builds

### Performance Optimierung
- Cache Flutter Dependencies
- Parallele Job-Ausführung
- Conditional Job Execution

## Sicherheit

- Alle Secrets werden verschlüsselt gespeichert
- Code Signing erfolgt in isolierten Umgebungen
- Security Scans werden bei jedem Build durchgeführt
- Dependencies werden auf Sicherheitslücken geprüft

## Support

Bei Problemen:
1. Überprüfe die GitHub Actions Logs
2. Konsultiere die Flutter Dokumentation
3. Erstelle ein Issue im Repository
4. Kontaktiere das Entwicklungsteam
