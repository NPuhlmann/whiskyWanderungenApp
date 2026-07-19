# Bekannte Abweichungen

Diese Seite hält den Stand fest, an dem der Code von den dokumentierten
Entscheidungen abweicht, sowie Altlasten aus früheren Umbauten. Sie ist ein
Inventar, keine Aufgabenliste: die Umsetzung wird über GitHub-Issues verfolgt,
die jeweils verlinkt sind.

Zweck ist, dass niemand dieselbe Stelle ein zweites Mal für einen neuen Fehler
hält. Wer eine Abweichung ausräumt, entfernt hier den Eintrag im selben PR.

Erhoben am 19.07.2026 gegen `main`. Angaben mit Zeilennummern verschieben sich
mit der Zeit — im Zweifel gilt der Code.

## Zahlungen

### Schema-Abweichungen im Kaufpfad

Die Edge Function `create-payment-intent` schreibt in `orders` drei Werte, die
das Schema laut Migrationen nicht annimmt:

| Feld | Function | Migration `20260508120300_payment_tables.sql` |
| --- | --- | --- |
| `company_id` | wird gesetzt | Spalte existiert nicht; kein `ALTER TABLE` ergänzt sie |
| `delivery_type` | `'standard_shipping'` | `CHECK (delivery_type IN ('pickup','shipping'))`, Zeile 12 |
| `order_number` | wird nicht gesetzt, danach zurückgelesen | `NOT NULL UNIQUE` ohne Default und ohne Trigger, Zeile 8 |

Nach ADR-0003 sind die Migrationen die Schemaautorität. Weicht die deployte
Datenbank davon ab, ist das seinerseits eine Abweichung und vor einer Korrektur
zu klären.

### Kein Webhook für Zahlungsergebnisse

Es existieren nur die Edge Functions `create-payment-intent` und
`calculate-shipping`. Das Webhook-Secret wird in
`terraform-supabase/supabase/migrations/20260719120000_supabase_vault_stripe_secrets.sql`
im Vault abgelegt, aber
nichts konsumiert es.

Folge: Nach erfolgreicher Bestätigung über das Stripe-SDK schreibt weder Client
noch Server den Bestellstatus zurück. Bestellungen bleiben auf `pending`, und in
`payments` entsteht nie eine Zeile — `backend_api.dart` liest die Tabelle
ausschließlich.

### `PaymentRepository.createOrder` widerspricht ADR-0006

`lib/data/repositories/payment_repository.dart` legt clientseitig eine Bestellung
an und vertraut dabei einem übergebenen Betrag; zusätzlich wird der Grundpreis
über einen fest verdrahteten Abzug von `5.0` zurückgerechnet.

Der Kaufpfad benutzt diese Methode nicht — einziger Konsument ist
`order_tracking_view_model.dart`. Sie bleibt aber eine Vorlage, die niemand
übernehmen sollte.

### Apple Pay und Google Pay sind simuliert

Die Verfügbarkeitsprüfung in
`lib/data/services/payment/multi_payment_service.dart` wartet 100 ms und meldet
dann „verfügbar, wenn Konfiguration vorhanden". Tatsächlich angebunden ist nur
die Kartenzahlung. Die Oberfläche bietet die Methoden trotzdem an.

## Architektur

### Schichtenregel nicht durchgängig

ADR-0004 legt `Widget → ViewModel → Repository → Service → Supabase` fest.
Sämtliche ChangeNotifier unter `lib/data/providers/` halten stattdessen direkt
einen Service, und mehrere Admin-Widgets erzeugen sich ihren Service selbst.

Bewusst zugelassene Ausnahmen — hier wäre ein Repository reine Zeremonie:

| Service | Grund |
| --- | --- |
| `AgeGateService` | nur SharedPreferences, kein Supabase |
| `LocationService` | Geräte-GPS und Geometrie |
| `NavigationService` | In-Memory-Zustandsmaschine |
| `MultiPaymentService` | SDK-Initialisierung, keine Tabelle |
| `AnalyticsExportService` | formatiert bereits geladene Daten |

### ViewModels ohne Lebenszyklus

Login, Signup und Magic-Link erzeugen ihr ViewModel direkt im Router-Builder
(`lib/config/routing/router.dart`). Diese Objekte werden bei jedem Build neu
angelegt und nie `dispose`d. Korrektes Vorbild ist das Age-Gate, das einen
`ChangeNotifierProvider` verwendet.

Getrennt davon: `LocationService`, `NavigationService` und `MultiPaymentService`
werden als `.instance`-Singletons in Feldern gehalten statt über den Konstruktor
übergeben. Das macht `HikeMapViewModel` und `NavigationViewModel` nicht mockbar
— ein Testbarkeits-, kein Schichtenproblem.

### Web-Admin initialisiert Supabase nicht

`lib/main_web.dart` ruft weder `dotenv.load()` noch `Supabase.initialize()`;
`main()` ist nicht einmal asynchron. `AdminGuard` fragt aber
`isUserLoggedIn()` ab und trifft damit auf einen nicht initialisierten Client.
Das Web-Ziel ist zur Laufzeit entsprechend eingeschränkt.

### Admin-Routen sind auch mobil erreichbar

`router.dart` bindet dieselbe Liste ein, die das Web-Ziel verwendet. `/admin/*`
existiert damit auch in der mobilen App. Abgesichert ist das nur durch
`AdminGuard` auf UI-Ebene — die bindende Autorisierung liegt nach ADR-0002 in
den RLS-Policies.

### Routing-Details

- Der Teilbaum `hikeDetails → hikeMap` ist zweimal deklariert, einmal unter Home
  und einmal unter My Hikes, jeweils mit `.substring(1)`, um führende Schrägstriche
  aus den Konstanten zu entfernen.
- Daten werden über `state.extra` gereicht und ungeprüft gecastet; die
  Hike-Details lesen `'hike'` und `'isFromMyHikes'` aus einer `Map` per
  String-Schlüssel. Tippfehler fallen erst zur Laufzeit auf.

## Altlasten

| Gegenstand | Stand |
| --- | --- |
| `lib/domain/models/order.dart` | tot — nur noch von Tests referenziert |
| `lib/domain/models/simple_order.dart` | tot — nur sein eigener Test |
| `lib/UI/core/responsive_layout.dart` | zweite Klasse gleichen Namens neben `UI/shared/`, andere Breakpoints; nur die `shared`-Variante hat Tests |
| `lib/config/routing/admin_routes.dart` | 25 Routenkonstanten, von niemandem importiert; real gebaut werden 8 |
| `WebHomePage` in `lib/main_web.dart` | Demo-Seite ohne Route, Navigation nur `debugPrint` |
| `_handleInitialLink()` in `lib/main.dart` | leerer Rumpf mit einem `debugPrint` |

Lebendig und beide in Benutzung sind dagegen `basic_order.dart` (mobil) und
`enhanced_order.dart` (Backend-API und Provisionen). Die Tracking-Ansichten
importieren beide.

## Konventionen

- `lib/UI/` ist großgeschrieben, `lib/data`, `lib/domain` und `lib/config` nicht.
- Importpfade mischen paketabsolut (`package:whisky_hikes/UI/...`) und relativ
  (`../../UI/core/...`) für dieselben Dateien, teils innerhalb einer Datei.
- `pubspec.yaml` steht unverändert auf `1.0.0+1`; ein Versionsschema fehlt.
  `distribute.yml` leitet die Build-Nummer aus der Commit-Anzahl ab.
