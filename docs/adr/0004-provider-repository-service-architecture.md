# Provider, Repositories und Services als App-Architektur

Status: Akzeptiert

Die Flutter-Anwendung trennt Oberflaeche, UI-Zustand, fachliche Datenzugriffe
und Infrastruktur in `UI/`, `data/repositories/` und `data/services/`.
`Provider` stellt appweite Abhaengigkeiten bereit, `ChangeNotifier` repraesentiert
beobachtbaren UI-Zustand. Der beabsichtigte Datenfluss lautet
`Widget -> ViewModel -> Repository -> Service -> Supabase`.

Alternativen waeren direkte Supabase-Aufrufe in Widgets, ein anderes
State-Management oder eine strikt erzwungene Clean Architecture. Die gewaehlte
pragmatische Variante ermoeglicht Konstruktorinjektion, Mocking der externen
Grenzen und gemeinsame Services, ohne jede UI-nahe Komponente durch zusaetzliche
Abstraktionen zu zwingen.

Konsequenz: Neue fachliche Datenoperationen gehoeren in ein Repository oder
einen vorhandenen Service, nicht in Widgets oder ViewModels. Die Architektur ist
nicht vollstaendig strikt umgesetzt; vorhandene direkte Service-Zugriffe sind
Bestandsabweichungen und kein Muster fuer neue Funktionen.
