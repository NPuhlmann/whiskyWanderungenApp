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
