# Architektur

## Architekturstil

Das Projekt ist als Repository-/Service-Architektur mit Provider und
ViewModels organisiert. Die Struktur orientiert sich an Clean-Architecture-
Schichten, wird aber nicht strikt erzwungen: Einige UI-nahe Komponenten greifen
direkt auf Services zu. Praktisch gilt der folgende Datenfluss:

```text
Widget/Page -> ViewModel (ChangeNotifier) -> Repository -> Service -> Supabase
```

| Schicht | Verantwortung | Hauptpfade |
| --- | --- | --- |
| UI | Seiten, Widgets, ViewModels, Admin-UI | `lib/UI/` |
| Konfiguration | DI, Routing, Lifecycle, Lokalisierung | `lib/config/` |
| Datenzugriff | fachliche Zugriffsabstraktionen | `lib/data/repositories/` |
| Infrastruktur | Backend, Payment, Cache, Standort, Notifications | `lib/data/services/` |
| Domain | Freezed-Modelle, Enums, Extensions | `lib/domain/models/` |
| IaC | Supabase, SQL, Edge Functions | `terraform-supabase/` |

## Einstiegspunkte

### Mobile Anwendung

`lib/main.dart` ist der Standard-Einstieg:

1. Initialisiert Flutter und laedt `.env`.
2. Initialisiert `Supabase` mit URL und Anon Key.
3. Initialisiert `MultiPaymentService`; Fehler werden nicht zum Startabbruch.
4. Registriert alle globalen Abhaengigkeiten per `MultiProvider`.
5. Startet `MaterialApp.router` mit Sprach- und Theme-Konfiguration.
6. Beobachtet Supabase-Auth-Ereignisse und initialisiert Cache-Lifecycle-
   Bereinigung.

Die unterstuetzten Locales sind `de_DE` und `en_US`. Die ARB-Quellen liegen in
`lib/config/l10n/`, die Konfiguration in `l10n.yaml`.

### Web-Admin

`lib/main_web.dart` ist ein unabhaengiger Flutter-Web-Einstieg. Er verwendet
`AdminRouter.getAdminRoutes()` und startet auf `/admin/dashboard`. Das Target
wird mit `flutter build web --target lib/main_web.dart` gebaut.

## Dependency Injection und State

`lib/config/dependencies.dart` ist die zentrale Registrierung. Reine
Abhaengigkeiten werden mit `Provider<T>`, beobachtbare Zustaende mit
`ChangeNotifierProvider<T>` bereitgestellt.

Global registrierte Services umfassen unter anderem:

| Gruppe | Typen |
| --- | --- |
| Basis | `AuthService`, `BackendApiService`, `LocalCacheService`, `OfflineService` |
| Fachservices | Order-, Whisky-, Commission-, Team- und Analytics-Services |
| Repositories | Profil, Nutzer, Hikes, Hike-Bilder, Waypoints, Payments |
| Mobile ViewModels | Home, Hike-Details, Meine Hikes |
| Admin-Zustaende | Orders, Whisky, Commission, Team, Analytics, Dashboard, Routen |

`UserRepository` ist ein `ChangeNotifier` und zugleich die
`refreshListenable`-Quelle fuer `go_router`, damit Authentifizierungswechsel
Redirects ausloesen. Seitenbezogene ViewModels wie Login, Registrierung,
Profil, Checkout und Karte werden lokal erzeugt.

## Navigation und Berechtigungen

`lib/config/routing/router.dart` definiert die mobile Navigation.

| Pfad | Zweck |
| --- | --- |
| `/login`, `/signUp` | Authentifizierung |
| `/` | Home-Branch der Bottom-Navigation |
| `/myHikes` | gekaufte Wanderungen |
| `/profile` | Nutzerprofil |
| `/checkout` | Checkout, erwartet `BasicOrder` in `state.extra` |
| `/payment-success`, `/payment-failed` | Payment-Ergebnis |
| `/order-history`, `/order-tracking/:orderId` | Bestellansicht und Tracking |
| `/admin/*` | Admin-Routen |

Die drei Hauptbereiche sind als `StatefulShellRoute.indexedStack` mit einer
Bottom-Navigation umgesetzt. Der globale Redirect leitet nicht angemeldete
Personen nach `/login`; `/signUp` bleibt erreichbar. Hike-Details und Karte
erwarten jeweils Objekte in `GoRouterState.extra`.

Admin-Routen sind in `lib/UI/web/admin/admin_router.dart` gebuendelt und pro
Seite mit `AdminGuard` umgeben. Der Guard prueft den Auth-Status und
`profiles.role == 'admin'`. Das ist nur eine UX-Schranke: die verbindliche
Autorisierung muss immer durch Row Level Security und serverseitige Funktionen
erfolgen.

## Domain-Modell

Die meisten Domain-Modelle sind immutable Freezed-Klassen mit
JSON-Serialisierung. `Profile` verwendet bewusst `@unfreezed` und ist daher
veraenderbar. Die Quellen liegen in `lib/domain/models/`.

| Modellgruppe | Bedeutende Typen |
| --- | --- |
| Katalog | `Hike`, `Waypoint`, `TastingSet`, `WhiskySample` |
| Identitaet | `Profile`, `Company` |
| Commerce | `BasicOrder`, `EnhancedOrder`, Payment-Resultate, `DeliveryAddress` |
| Versand und Provision | `CompanyShippingRule`, `Commission` |
| Community | `Review`, `ReviewRating`, `ReviewStatistics` |
| Reporting | Analytics-Modelle unter `models/analytics/` |

### Fachregel: Tasting-Set

Jeder Hike hat genau ein Tasting-Set. Das Set ist im Hike-Preis enthalten:
`tasting_sets.hike_id` ist eindeutig, `price` hat den Standardwert `0.00` und
`is_included` den Standardwert `true`. Neue Logik darf keine optionale
Set-Auswahl oder einen separaten Set-Aufpreis einfuehren, ohne diese Fachregel
explizit zu aendern.

## Repositories und Services

`BackendApiService` in `lib/data/services/database/backend_api.dart` ist die
groesste Supabase-Fassade. Sie deckt Profile, Hikes, Bilder, Waypoints,
Bestellungen, Besitzrechte, Tasting-Sets, Reviews und Teile von Versand und
Tracking ab. `HikeService` und `ProfileService` kapseln einzelne Bereiche
weiter.

| Repository | Aufgabe |
| --- | --- |
| `HikeRepository` | verfuegbare und gekaufte Hikes, Pagination |
| `ProfileRepository` | cache-first Profil- und Avatarzugriff |
| `UserRepository` | Authentifizierung und Auth-Status |
| `HikeImagesRepository` | Bilddaten zu Hikes |
| `PaymentRepository` | Orders, Zahlungen und Status |
| `TastingSetRepository` | Sets, Samples, Suche und Verwaltung |
| `ReviewRepository` | Reviews, Bewertungen und Statistiken |
| `OfflineFirstHikeRepository` | Cache-Strategien fuer Hikes |
| `OfflineFirstWaypointRepository` | Waypoints einer Wanderung, network-first gecacht |

## Offline und Cache

Es bestehen zwei getrennte Caches:

| Komponente | Inhalt | Speichermedium | Regeln |
| --- | --- | --- | --- |
| `LocalCacheService` | Profile und Avatare | `SharedPreferences`, Application Documents | Profil 24 h, Bild 7 Tage, Bildcache 50 MB |
| `OfflineService` | Hikes, Waypoints, Tasting-Sets und Listen | `SharedPreferences`, Cache-Verzeichnis | Hikes 12 h, Waypoints 6 h, Orders 48 h, Bilder 7 Tage |

`OfflineFirstHikeRepository` bietet `cacheFirst`, `networkFirst`,
`cacheOnly`, `networkOnly` und `staleWhileRevalidate`. Die allgemeine
`DataSyncService`-Queue kann Waypoint-Aktionen persistent verarbeiten, wird
aber vom mobilen Einstieg aktuell nicht initialisiert. Offline-Aenderungen an
Waypoints sind deshalb vor produktiver Nutzung end-to-end zu verifizieren.
