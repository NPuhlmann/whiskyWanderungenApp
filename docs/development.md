# Entwicklung

## Code- und Modellkonventionen

Der Produktivcode folgt den Flutter-Lints aus `flutter_lints`. Vor einem
Commit muss der geaenderte Dart-Code formatiert sein:

```bash
dart format lib/
flutter analyze
```

Die maximale Zeilenlaenge laut Projektkonvention ist 80 Zeichen. Oeffentliche
APIs erhalten `///`-Kommentare; einfache Zuweisungen werden nicht kommentiert.
Neue Abhaengigkeiten sollen per Konstruktor injiziert werden.

### Freezed und JSON

Modelle verwenden Freezed 3.x und `json_serializable`. Eine Freezed-Klasse
muss als `abstract class` definiert sein:

```dart
@freezed
abstract class Example with _$Example {
  const factory Example({required String id}) = _Example;

  factory Example.fromJson(Map<String, dynamic> json) =>
      _$ExampleFromJson(json);
}
```

Nach jeder Modell-Aenderung ausfuehren:

```bash
dart run build_runner build
```

Die erzeugten Dateien `*.freezed.dart`, `*.g.dart` und Test-Mocks werden nicht
manuell bearbeitet. Flutter-Lokalisierung wird bei Bedarf mit
`flutter gen-l10n` erzeugt; ARB-Dateien liegen in `lib/config/l10n/`.

## Neue Funktion implementieren

Die kleinste passende Umsetzung ist in der Regel:

1. Fachmodell und Datenbankvertrag klaeren.
2. Repository oder vorhandenen Service um die Datenoperation erweitern.
3. Die Abhaengigkeit in `lib/config/dependencies.dart` registrieren, falls sie
   appweit geteilt wird.
4. Ein fokussiertes `ChangeNotifier`-ViewModel mit Lade-, Fehler- und
   Erfolgzustand verwenden.
5. Die Seite ueber Provider anbinden und Navigation in `routes.dart` plus
   `router.dart` ergaenzen.
6. Test, Formatierung, Analyse und den relevanten Build ausfuehren.

Asynchrone ViewModels setzen den Ladezustand vor dem Aufruf und raeumen ihn
immer in `finally` auf:

```dart
Future<void> load() async {
  _isLoading = true;
  notifyListeners();

  try {
    _data = await _repository.load();
  } catch (error) {
    _error = error.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

## Tests

Die Teststruktur umfasst `test/domain/`, `test/data/`, `test/UI/`,
`test/services/`, `test/repositories/` und `test/integration/`. Der breitere
Testbaum hat jedoch gedriftete Mocks und Fixtures und ist daher nicht das
gegenwaertige CI-Gate. `analysis_options.yaml` schliesst `test/**` momentan
aus.

| Befehl | Erwartung |
| --- | --- |
| `flutter test test/widget_test.dart` | aktueller, gruener CI-Smoke-Test |
| `flutter test` | kann wegen bekannter Mock-/Fixture-Drift fehlschlagen |
| `flutter test test/domain/` | nach Angleichung der jeweiligen Tests nutzen |
| `flutter test test/widget_test.dart --coverage` | Coverage fuer den Smoke-Test |

Neue Features sollen trotzdem mit passenden Tests beginnen oder mindestens
ergaenzt werden. Externe Grenzen wie Supabase, Storage und Payment werden
gemockt. Nach jeder Signaturaenderung an produktivem Code muessen betroffene
Mocks neu generiert oder angepasst werden.

## CI

`.github/workflows/ci.yml` laeuft bei Pushes nach `main` und `develop` sowie
bei Pull Requests nach `main`. Die CI setzt Flutter `3.41.7` ein und kopiert
`.env.example` nach `.env`.

| Job | Inhalt |
| --- | --- |
| `test` | Codegen, `flutter analyze`, Format-Check fuer `lib/`, Smoke-Test |
| `security-scan` | Trivy-Dateisystemscan, SARIF-Upload |
| `build-android` | Debug-APK und Debug-App-Bundle |
| `build-ios` | iOS-Debug-Build ohne Codesign |
| `build-web` | Web-Admin mit `--target lib/main_web.dart` |
| `dependency-check` | `flutter pub outdated` und Dependency Tree |

Lokal vor einem Pull Request mindestens ausfuehren:

```bash
dart run build_runner build
flutter analyze
dart format --set-exit-if-changed lib/
flutter test test/widget_test.dart
flutter build apk --debug
```

## Entwicklerdokumentation

Die technische Dokumentation wird mit MkDocs gebaut. Die Python-Abhaengigkeit
ist getrennt von den Flutter-Abhaengigkeiten in `docs/requirements.txt`
festgehalten:

```bash
python3 -m pip install -r docs/requirements.txt
mkdocs serve
mkdocs build --strict
```

`mkdocs serve` stellt die Dokumentation lokal mit automatischem Reload bereit.
`mkdocs build --strict` ist der verbindliche Build-Check fuer Navigation und
interne Links. Die Konfiguration liegt in `mkdocs.yml`; der generierte Ordner
`site/` ist ein Build-Artefakt und wird nicht versioniert.

## Build und Release

| Ziel | Befehl |
| --- | --- |
| Android Debug | `flutter build apk --debug` |
| Android Release APK | `flutter build apk --release` |
| Android Release Bundle | `flutter build appbundle --release` |
| iOS Debug | `flutter build ios --debug --no-codesign` |
| iOS Release | `flutter build ios --release` |
| Web-Admin | `flutter build web --target lib/main_web.dart` |

Release-Credentials kommen aus GitHub Secrets. Die relevanten Android- und
iOS-Secrets sind in `README.md` und den Release-Workflows beschrieben. Sie
werden nie in Git, `.env.example` oder Flutter-Assets gespeichert.
