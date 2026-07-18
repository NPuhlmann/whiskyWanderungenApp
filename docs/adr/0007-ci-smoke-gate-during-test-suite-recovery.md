# CI-Smoke-Gate waehrend der Test-Bereinigung

Status: Akzeptiert, befristet

CI sichert derzeit Codegenerierung, Analyse und Formatierung von `lib/`, einen
gezielten Widget-Smoke-Test sowie Android-, iOS- und Web-Builds ab. Der breitere
Testbaum ist wegen gedrifteter Mocks und Fixtures aus der Analyse ausgeschlossen
und nicht Teil des blockierenden Gates. Diese Einschraenkung haelt das Repository
lieferfaehig, solange die Tests schrittweise wieder an die Produktionssignaturen
angepasst werden.

Alternativen waeren ein sofort blockierender Gesamttestlauf, das Loeschen der
gedrifteten Tests oder ein dauerhaft reiner Build-Gate. Der aktuelle Kompromiss
bewahrt mindestens eine ausfuehrbare App auf allen ausgelieferten Zielen, ohne
bekannte Testschuld als neuen Codefehler auszugeben.

Konsequenz: Diese Entscheidung ist kein Ersatz fuer fachliche Tests. Neue
Funktionen erhalten fokussierte Tests; der ausgeschlossene Testbaum wird in
abgrenzbaren Schritten reaktiviert. Sobald der Gesamttestbaum wieder stabil ist,
wird dieses ADR durch eine Entscheidung fuer den vollstaendigen Test-Gate
ersetzt.

**Status (2026-07-18):** Issue #7 erweitert das Gate von einem einzelnen
Smoke-Test auf eine explizite Include-Liste: `widget_test.dart` plus
`auth_service_test.dart`, `profile_repository_test.dart`,
`hike_details_view_model_test.dart` und `checkout_view_model_test.dart`
(Auth, Nutzerdaten, Hike-Buchung, Payment-Flow). Die Analyzer-Exclude-Liste
in `analysis_options.yaml` wurde von einem pauschalen `test/**` auf gezielte
Excludes pro verbleibender Testdatei umgestellt, sodass die vier Testdateien
plus `test/mocks/`, `test/test_helpers.dart` und `test/data/test_helpers.dart`
wieder analysiert werden. Weitere Dateien werden nach demselben Muster
schrittweise reaktiviert.
