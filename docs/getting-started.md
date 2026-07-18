# Einstieg

## Voraussetzungen

| Werkzeug | Verwendeter Stand |
| --- | --- |
| Flutter | CI: `3.41.7`, Paket: `>=3.35.1 <4.0.0` |
| Dart | mit Flutter, Paket: `^3.9.0` |
| Supabase | Projekt-URL und oeffentlicher Anon Key |
| Android Studio oder Xcode | fuer Emulatoren bzw. Geraete |
| Terraform, Supabase CLI, Node.js | nur fuer Provisionierung und Edge Functions |

Pruefe die lokale Flutter-Installation mit:

```bash
flutter doctor -v
```

## Mobile App lokal starten

Die Datei `.env` ist ein Flutter-Asset und muss deshalb bereits vor
`flutter pub get`, Analyse, Tests oder einem Build vorhanden sein.

```bash
cp .env.example .env
flutter pub get
dart run build_runner build
flutter run
```

Trage vor einem echten Backend-Test mindestens diese Werte in `.env` ein:

```dotenv
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<public-anon-key>
DEV_MODE=true
```

`lib/main.dart` laedt die Datei mit `flutter_dotenv`, erzwingt HTTPS fuer die
Supabase-URL, initialisiert Supabase und startet den `MultiProvider`. Ein
fehlgeschlagener Payment-Service-Start wird geloggt, blockiert den Appstart
aber nicht.

!!! warning "Keine serverseitigen Geheimnisse"
    `.env` wird ueber `pubspec.yaml` als App-Asset gebuendelt. Werte darin sind
    aus einem ausgelieferten App-Bundle auslesbar. Nur clientseitig sichere
    Werte wie `SUPABASE_URL`, `SUPABASE_ANON_KEY` und oeffentliche Stripe-Keys
    gehoeren hinein. Niemals Service-Role-, Supabase-Access- oder Stripe
    Secret-Keys eintragen.

## Web-Admin bauen oder starten

Der Web-Admin ist ein separater Einstiegspunkt. Er wird nicht aus
`lib/main.dart` aufgebaut.

```bash
flutter run -d chrome --target lib/main_web.dart
flutter build web --target lib/main_web.dart
```

`lib/main_web.dart` startet mit `/admin/dashboard` und registriert nur
`AuthService` und `AdminProvider`. Admin-Seiten selbst werden ueber
`AdminGuard` geschuetzt. Fuer produktive Admin-Nutzung muss Supabase vorher
initialisiert werden; der gegenwaertige Web-Einstieg ist vor allem eine
einfache Admin-Oberflaeche bzw. ein Build-Target.

## Lokale Infrastruktur

Ein vorhandenes Supabase-Projekt kann direkt verwendet werden: URL und Anon
Key aus dem Supabase-Dashboard in `.env` eintragen. Fuer ein neues Projekt
liegen Terraform-Variablen unter `terraform-supabase/`.

```bash
cd terraform-supabase
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

Die vollstaendige Provisionierung ist in
[Daten und Infrastruktur](backend.md) beschrieben. Vor `terraform apply`
muessen die sensiblen Variablen lokal gesetzt sein; sie duerfen nicht in
`.env` der Flutter-App oder in Git landen.

## Nuetzliche Befehle

| Befehl | Zweck |
| --- | --- |
| `flutter pub get` | Paketabhaengigkeiten laden |
| `dart run build_runner build` | Freezed-, JSON- und Mockito-Code generieren |
| `dart run build_runner watch` | Codegen im Watch-Modus |
| `flutter analyze` | statische Analyse |
| `dart format lib/` | Produktivcode formatieren |
| `flutter test test/widget_test.dart` | aktueller CI-Smoke-Test |
| `flutter run` | mobile Anwendung starten |
| `flutter build apk --debug` | Android-Debug-APK erzeugen |
| `flutter build ios --debug --no-codesign` | iOS-Debug-Build ohne Signing |

Die Hintergruende zu Codegen, Tests und CI stehen unter
[Entwicklung](development.md).
