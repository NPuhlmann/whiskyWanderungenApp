# Tasting-Set ist Bestandteil eines Hikes

Status: Akzeptiert

Jeder Hike umfasst genau ein Tasting-Set. Das Set ist automatisch enthalten und
wird nicht separat bepreist oder im Checkout ausgewaehlt. Das Domain-Modell
setzt `price` standardmaessig auf `0.0` und `isIncluded` auf `true`; die
Migration modelliert die Zuordnung mit `tasting_sets.hike_id` und entfernt die
fruehere Zuordnungstabelle fuer Bestellungen und Tasting-Sets.

Alternativen waeren mehrere oder optionale Sets pro Hike, ein separat
bepreistes Set oder eine freie Sample-Auswahl. Die gewaehlte Produktregel haelt
Katalog, Checkout und Fulfillment bewusst einfach: Der Hike-Preis deckt das
zugehoerige Set ab.

Konsequenz: Neue Checkout- oder Kataloglogik darf kein optionales Set und keinen
Set-Aufpreis einfuehren. Die Datenbank erzwingt derzeit hoechstens ein Set pro
Hike sowie Standardwerte, aber nicht die vollstaendige Fachregel. Falls diese
Garantie benoetigt wird, muss sie durch eine eigene Schema- und
Datenmigrationsentscheidung verstaerkt werden.
