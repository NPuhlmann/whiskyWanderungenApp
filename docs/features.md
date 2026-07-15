# App-Flows

## Authentifizierung und Profile

`AuthService` kapselt Supabase E-Mail-/Passwort-Login und Registrierung. Bei
der Registrierung wird fuer produktive Bestaetigungen der Deep Link
`whiskyhikes://email-confirm` verwendet. Android und iOS registrieren dieses
Schema.

Der Auth-Status steuert die mobile Route. Profile werden ueber
`ProfileRepository` geladen; der Repository nutzt den `LocalCacheService` fuer
cache-first Zugriff auf Profildaten und Avatarbilder.

## Hike-Katalog und Besitz

1. Das Home-ViewModel laedt verfuegbare Hikes ueber `HikeRepository`.
2. Favoriten werden lokal in `SharedPreferences` verwaltet.
3. Der Kauf erzeugt Bestelldaten und Zahlungsdaten.
4. Die Besitzbeziehung wird ueber `purchased_hikes` abgebildet.
5. `MyHikesViewModel` laedt die gekauften Wanderungen des aktuellen Nutzers.

Hike-Bilder, Tasting-Sets, Whisky-Samples und Waypoints werden in den
Detailansichten nachgeladen. Datenzugriffe bleiben moeglichst im Repository;
neue UI-Logik soll Backend-Aufrufe nicht duplizieren.

## Karte, GPS und Waypoint-Navigation

Die Kartenansicht verwendet `flutter_map` mit OpenStreetMap und `latlong2`.
`LocationService` basiert auf `geolocator` und fordert Standortberechtigungen
an. `HikeMapViewModel` kombiniert Position, Waypoints und
`NavigationService`.

| Regel | Wert |
| --- | --- |
| Standort-Genauigkeit | hoch |
| Bewegungsfilter | 5 m |
| Waypoint als erreicht | Distanz <= 10 m |
| Kartenanzeige "in der Naehe" | standardmaessig <= 50 m |
| Berechnete Gehgeschwindigkeit | 4 km/h |
| Wechsel zum naechsten Ziel | 3 Sekunden nach Erreichen |

Waypoints werden nach `orderIndex` sortiert. Fehlen geladene Waypoints oder
haben sie nahezu gleiche Koordinaten, erzeugt das ViewModel lokale
Test-Waypoints. Dieser Fallback ist als Entwicklungs- bzw.
Datenqualitaetsmechanismus zu verstehen, nicht als fachlich korrekter Inhalt.

## Checkout und Zahlung

Der aktuelle Standardfluss verwendet `BasicOrder`:

1. `PaymentRepository.createOrder()` schreibt einen Eintrag in `orders` und
   einen zugeordneten Eintrag in `order_items`.
2. Der Checkout validiert Zahlungsmethode und bei Versand Adresse.
3. `PaymentRepository.processPayment()` ruft `MultiPaymentService` auf.
4. Das Ergebnis wird als Eintrag in `payments` gespeichert.
5. Bei Erfolg wird `orders.status` auf `confirmed` gesetzt.
6. Die UI navigiert zum Order-Tracking oder zur Erfolgseite.

| Zahlungsmethode | Aktueller Implementierungsstand |
| --- | --- |
| Karte | Stripe Payment Intent und Bestaetigung im SDK |
| Apple Pay | Konfiguration vorhanden, Zahlung simuliert |
| Google Pay | Konfiguration vorhanden, Zahlung simuliert |
| SEPA, Sofort, Giropay, iDEAL | Enums vorhanden, nicht implementiert |
| PayPal | nicht integriert |

!!! danger "Zahlungsintegration vor Produktivgang abschliessen"
    Simulierte Wallet-Zahlungen duerfen nicht als echte Transaktionen
    behandelt werden. Payment Intents muessen in Produktion durch die
    serverseitige Supabase Edge Function erstellt werden. Der Stripe Secret
    Key darf nie vom Flutter-Client aus verwendet werden.

`EnhancedOrder` erweitert das Modell fuer Multi-Vendor, Steuer, Versand,
Carrier, Tracking und Statushistorie. Die Standard-Tracking-Ansicht laedt
derzeit faktisch `BasicOrder`; offene Enhanced-Order-Pfade sind vor dem
Produktivbetrieb durchgaengig zu implementieren und zu testen.

## Versand und Multi-Vendor

Anbieter haben eigene `CompanyShippingRule`-Datensaetze. Der
`ShippingCalculationService` ruft die Edge Function `calculate-shipping` auf,
cacht Ergebnisse fuer fuenf Minuten und besitzt Fallbacks fuer Inland, DACH,
EU und internationale Ziele.

Die Edge Function wertet Anbieter- und Standardversandregeln aus. Die
zugehoerigen Daten liegen in `companies`, `company_shipping_rules` und
`default_shipping_rules`.

## Benachrichtigungen

`SupabaseNotificationService` registriert lokale Notifications und beobachtet
Supabase-Realtime-Ereignisse fuer `orders` und `enhanced_orders`. So werden
Status- und Tracking-Aenderungen lokal angezeigt. Eine persistente
Notification-Inbox ist gegenwaertig noch nicht vollstaendig umgesetzt.

## Admin-Web

Der Web-Admin hat Seiten fuer:

| Bereich | Beispiele |
| --- | --- |
| Dashboard | Kennzahlen und Uebersicht |
| Routen | Hikes und Waypoints verwalten |
| Bestellungen | Bestell- und Statusverwaltung |
| Whisky | Tasting-Sets und Samples |
| Analytics | Sales, Kunden, Routenleistung, Exporte |
| Team und Finanzen | Rollen, Provisionen und Abrechnungsnahe Daten |

Die aktiven Routen sind `/admin/dashboard`, `/admin/routes`, `/admin/orders`,
`/admin/whisky`, `/admin/analytics`, `/admin/team`, `/admin/finances` und
`/admin/settings`. Einige Routen-Konstanten fuer Detail- oder Erstellseiten
sind vorhanden, aber noch nicht als `GoRoute` umgesetzt.
