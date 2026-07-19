# CI/CD für Whisky Hikes

Zwei Workflows, sonst nichts.

## `.github/workflows/ci.yml` — CI

**Trigger:** Push auf `main`/`develop`, Pull Requests nach `main`/`develop`.

**Blockierende Gates im Job `test`:**

- `dart run build_runner build --delete-conflicting-outputs`, danach
  `git diff --exit-code` — die 69 eingecheckten `.g.dart`/`.freezed.dart`/
  `.mocks.dart` müssen zur Generierung passen
- `flutter analyze` (Scope für `test/` steht in `analysis_options.yaml`)
- `dart format --set-exit-if-changed lib/ test/`
- `flutter test` gegen eine **explizite Include-Liste von 9 Dateien** — nicht
  den ganzen Baum. Der Rest steht unter dem Burn-down #46–#51. Es laufen
  **keine** Integrationstests in CI.

**Job `security-scan`:** Trivy läuft zweimal — einmal als SARIF-Upload in den
Security-Tab, einmal blockierend auf `CRITICAL,HIGH` (`ignore-unfixed`).

**Jobs `build-android` / `build-ios` / `build-web`:** Debug-Builds, hängen an
`test`. `build-web` baut gegen `lib/main_web.dart` (Admin-Entry).

Alle Actions sind auf Commit-SHAs gepinnt. `permissions: contents: read` auf
Workflow-Ebene, `security-events: write` nur im Scan-Job.

## `.github/workflows/distribute.yml` — Auslieferung

**Trigger:** ausschließlich `workflow_dispatch`. Vorher `ci.yml` grün laufen
lassen — die Reihenfolge wird nicht erzwungen.

Baut signierte Release-Artefakte und lädt sie nach TestFlight (Internal) und in
den Play-Store-Track *internal*. Der Workflow prüft aktiv, ob das AAB wirklich
signiert ist, und bricht sonst ab.

### Benötigte GitHub Secrets

Die Namen stammen aus `distribute.yml` — andere Schreibweisen führen zu einem
fehlschlagenden Workflow.

#### Android

```
ANDROID_KEYSTORE_BASE64            # Base64-kodierter Upload-Keystore
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON   # Play-Console-Service-Account (JSON)
```

Die Signier-Credentials werden als `ORG_GRADLE_PROJECT_MYAPP_UPLOAD_*` an
Gradle durchgereicht, es wird keine `key.properties` geschrieben.

#### iOS

```
IOS_P12_BASE64
IOS_P12_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_PROVISIONING_PROFILE_NAME
APPLE_TEAM_ID
APP_STORE_CONNECT_API_KEY_ISSUER_ID
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_API_KEY_CONTENT
```

`distribute.yml` erzeugt die `ExportOptions.plist` zur Laufzeit aus
`APPLE_TEAM_ID` und `IOS_PROVISIONING_PROFILE_NAME`. Es gibt keine
Plist-Vorlage im Repo mehr, die von Hand angepasst werden müsste.

### Keystore erzeugen

```bash
keytool -genkey -v -keystore whisky-hikes.keystore \
  -alias whisky-hikes -keyalg RSA -keysize 2048 -validity 10000
base64 -i whisky-hikes.keystore | tr -d '\n' > keystore-base64.txt
```

## Versionierung

Die Version kommt aus `pubspec.yaml`. Die Build-Nummer erzeugt
`distribute.yml` aus `git rev-list --count HEAD` und ist damit monoton
steigend — Stores verlangen das.

## Offene Punkte

- Flutter-Version ist in `ci.yml` und `distribute.yml` separat gepinnt
  (`3.41.7`); lokal läuft 3.44.6. GitHub kennt kein workflow-übergreifendes
  `env`.
- `--fatal-infos` ist nicht gesetzt, solange der eine verbleibende
  `deprecated_member_use`-Hinweis existiert.
- Store-Konto-Entscheidungen und `applicationId`: siehe #53.
