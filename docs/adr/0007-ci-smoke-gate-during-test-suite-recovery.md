# CI-Smoke-Gate waehrend der Test-Bereinigung

Status: Akzeptiert, befristet

CI sichert derzeit Codegenerierung, Analyse und Formatierung von `lib/`, einen
gezielten Widget-Smoke-Test sowie Android-, iOS- und Web-Builds ab. Der breitere
Testbaum ist aus der Analyse ausgeschlossen und nicht Teil des blockierenden
Gates. Diese Einschraenkung haelt das Repository lieferfaehig, solange die Tests
schrittweise wieder angepasst werden.

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

**Status (2026-07-19):** Die Include-Liste in `ci.yml` umfasst inzwischen neun
Dateien, nicht fuenf.

Eine Messung mit Flutter 3.44.6 korrigiert ausserdem die urspruengliche
Begruendung dieses ADR. `flutter test` ergibt 1078 gruene und 152 rote Tests bei
**null Kompilier- oder Ladefehlern** — der Testbaum uebersetzt vollstaendig. Die
Fehlschlaege sind fachliche Assertion-Fehler, nicht die gedriftete Mock- und
Fixture-Landschaft, mit der die Ausschlussliste begruendet wurde. Zwei Dateien
uebersetzen tatsaechlich nicht, weil sie auf entfernte private Member zugreifen;
das ist in #46 erfasst.

Der verbleibende Burn-down ist damit deutlich kleiner als angenommen und in
#46 bis #51 nach Ursachen zerlegt. Die Zahlen schwanken leicht zwischen Laeufen
(ein zweiter Lauf: 1082/148) und eignen sich nicht als Abnahmekriterium.

Sobald der Gesamttestbaum stabil ist, wird dieses ADR wie vorgesehen durch eine
Entscheidung fuer den vollstaendigen Test-Gate ersetzt.
