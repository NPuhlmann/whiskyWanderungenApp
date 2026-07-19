# Purchase-Lesemodul getrennt vom Intake, Port spricht Rows

Status: Akzeptiert

Der Purchase-Zugriff im Client wird auf zwei Module aufgeteilt, und der
Testseam darunter tauscht Datenbankzeilen aus, nicht Domaenenobjekte.

## Zwei Module statt einem

`PurchaseIntakeRepository` (Schreiben) und `PurchaseRepository` (Lesen und
Statusuebergaenge) bleiben getrennte Module mit getrennten Interfaces.

Beide Haelften nutzen unterschiedliche Transporte: Intake ruft die Edge
Function `create-payment-intent` ueber `functions.invoke` auf und bestaetigt
ueber das Stripe-SDK; Lesen und Statusuebergaenge sind gewoehnliche
Postgrest-Abfragen unter RLS. Statusuebergaenge betreffen Fulfilment
(Versand, Tracking), nicht Zahlung, und gehoeren deshalb nicht hinter die
Edge Function.

Alternative waere ein einziges Purchase-Modul. Der entscheidende Einwand ist
die Testoberflaeche: Der Fake fuer Intake bildet eine Edge-Function-Antwort
nach, der Fake fuer Lesen eine Liste von Purchases. Ein gemeinsames Modul
braucht ein Test-Double, das beides schlecht kann.

Konsequenz: "Purchase" benennt zwei Module. Wer den Code liest, muss wissen,
auf welcher Seite er steht. Das wird ueber Benennung geloest, nicht ueber
Zusammenlegen.

## Der Port spricht Rows

Der Port unter `PurchaseRepository` gibt `Map<String, dynamic>` beziehungsweise
`List<Map<String, dynamic>>` fuer wenige benannte Abfragen zurueck. Das Mapping
Row → `Purchase`, die Validierung der `PurchaseStatus`-Uebergaenge und die
Fehlerpolitik liegen im Modul, nicht im Adapter.

Zwei Alternativen wurden verworfen:

Ein generischer Query-Port (`select(table, filters)`) ist nur eine andere Haut
fuer Postgrest. Der In-Memory-Adapter muesste eine Query-Engine nachbauen, um
nuetzlich zu sein.

Ein Port, der `Purchase` spricht, laesst dem Modul nichts mehr zu tun. Mapping
und Validierung wandern in die Adapter, und der In-Memory-Fake muss sie
nachbauen, um ehrlich zu bleiben. Genau dieser Fehler steckt in
`dashboard_metrics_service_test`, wo eine Kopie der Implementierung im
Testfile liegt und die echten Methoden ungeprueft bleiben.

Praktisches Kriterium: Verlangt der In-Memory-Adapter mehr als Maps zu
speichern und zurueckzugeben, sitzt der Port an der falschen Stelle.

Konsequenz: Rows sind untypisiert. Eine Schemaaenderung schlaegt als
Mapping-Fehler im Modul auf, nicht als Compile-Fehler am Port. Das ist
akzeptiert — es ist eine Mapping-Funktion in einem Modul, und dort soll der
Fehler auch landen.

## Geltungsbereich

Dieses ADR beschreibt das Muster fuer den Purchase-Slice. Die uebrigen
Konzepte in `BackendApiService` (Hike, Hike Image, Waypoint, Tasting Set,
Review, Profile, Commission) folgen demselben Muster, wenn sie geschnitten
werden. Der Admin-Web-Lesepfad ueber `OrderManagementService` bleibt vorerst
untypisiert und ausserhalb dieses ADR.
