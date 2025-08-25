# GitHub Actions Workflows

Dieses Verzeichnis enthält alle GitHub Actions Workflows für die Whisky Hikes Flutter App.

## Übersicht der Workflows

### 1. CI Pipeline (`ci.yml`)
**Zweck:** Kontinuierliche Integration und Qualitätssicherung

**Trigger:**
- Push auf `main` oder `develop` Branch
- Pull Requests auf `main` Branch

**Funktionen:**
- ✅ Flutter Tests (Unit, Widget, Integration)
- ✅ Code Analyse und Formatierung
- ✅ Security Scanning mit Trivy
- ✅ Multi-Platform Builds (Android, iOS, Web)
- ✅ Dependency Checks
- ✅ Coverage Reports

### 2. Release Pipeline (`release.yml`)
**Zweck:** Manuelle Release-Builds und automatische GitHub Releases

**Trigger:**
- Manueller Workflow Dispatch
- GitHub Release Events

**Funktionen:**
- 🔐 Code Signing für Android und iOS
- 📱 Release Builds (APK, AAB, IPA)
- 🏷️ Automatische Versionserhöhung
- 📦 GitHub Release Assets
- 🔄 Rollback bei Fehlern

### 3. Advanced Release (`release-with-rollback.yml`)
**Zweck:** Erweiterte Release-Pipeline mit Rollback-Funktionalität

**Trigger:**
- Manueller Workflow Dispatch mit Eingabeparametern
- GitHub Release Events

**Funktionen:**
- 🎯 Release Type Selection (patch/minor/major)
- 🧪 Optionale Test-Ausführung
- 🌿 Release Branch Management
- 🚀 Vollständige GitHub Release Erstellung
- 🔄 Automatischer Rollback bei Fehlern
- 🧹 Post-Release Cleanup

## Workflow-Ausführung

### Automatische CI
```bash
# Bei jedem Push auf main/develop
git push origin main
# CI-Pipeline läuft automatisch
```

### Manueller Release
1. Gehe zu **Actions** → **Release Build**
2. Klicke **Run workflow**
3. Wähle Branch aus
4. Klicke **Run workflow**

### Erweiterter Release
1. Gehe zu **Actions** → **Advanced Release with Rollback**
2. Klicke **Run workflow**
3. Konfiguriere Parameter:
   - **Release Type**: patch/minor/major
   - **Target Branch**: main
   - **Skip Tests**: false (empfohlen)
4. Klicke **Run workflow**

## Konfiguration

### GitHub Secrets
Folgende Secrets müssen in den Repository-Einstellungen konfiguriert werden:

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

### Flutter Version
Alle Workflows verwenden Flutter 3.19.0. Diese Version kann in den Workflow-Dateien angepasst werden:

```yaml
env:
  FLUTTER_VERSION: '3.19.0'
```

## Build-Artefakte

### CI Builds
- **Android Debug**: APK und AAB
- **iOS Debug**: iOS Build (ohne Code Signing)
- **Web**: Web Build

### Release Builds
- **Android Release**: Signierte APK und AAB
- **iOS Release**: Signierte IPA
- **GitHub Release**: Alle Builds als Release Assets

## Monitoring

### Workflow-Status
- Überwache den Status in der **Actions** Tab
- Erhalte Benachrichtigungen bei Erfolg/Fehler
- Überprüfe Logs bei Problemen

### Coverage Reports
- Code Coverage wird bei jedem Test-Lauf generiert
- Upload zu Codecov (falls konfiguriert)
- Coverage-Dateien als Build-Artefakte verfügbar

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

### Debug-Modus
Füge `ACTIONS_STEP_DEBUG: true` zu den Repository Secrets hinzu für detaillierte Logs.

## Erweiterte Features

### Security Scanning
- Trivy Vulnerability Scanner
- Dependency Security Checks
- Code Quality Analysis

### Performance Optimierung
- Parallele Job-Ausführung
- Caching von Dependencies
- Conditional Job Execution

### Notifications
- Erfolgs-/Fehlermeldungen
- Integration mit externen Services möglich
- Slack/Teams Webhooks unterstützt

## Support

Bei Problemen mit den Workflows:
1. Überprüfe die GitHub Actions Logs
2. Konsultiere die Flutter Dokumentation
3. Erstelle ein Issue im Repository
4. Kontaktiere das Entwicklungsteam

## Lizenz

Diese Workflows sind Teil des Whisky Hikes Projekts und unterliegen der gleichen Lizenz.
