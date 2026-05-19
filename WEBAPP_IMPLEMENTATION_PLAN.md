# Web-App für Unternehmen – Implementierungsplan

Stand: 2026-05-19

Dieser Plan beschreibt den Aufbau der Flutter-Web-App, die Whisky-Läden und
Brennereien als Admin-Dashboard nutzen (Routen, Bestellungen, Tasting-Sets,
Provisionen, Team, Analytics). Die App teilt sich Codebase mit der mobilen
Whisky-Hikes-App und unterscheidet sich nur durch ein responsives Layout und
admin-spezifische Pages unter `lib/UI/web/admin/`.

---

## 1. Architektur

### 1.1 Code-Sharing zwischen Mobile und Web
- **Domain & Data Layer** sind plattform-neutral und werden von beiden Apps
  geteilt (`lib/domain/`, `lib/data/`).
- **Mobile-UI** liegt unter `lib/UI/mobile/` und nutzt Bottom-Navigation.
- **Admin-UI** liegt unter `lib/UI/web/admin/` und nutzt Sidebar/AppBar.
- **Responsive Helper** (`lib/UI/web/admin/dashboard/.../responsive_layout.dart`)
  schaltet zwischen Mobile-/Tablet-/Desktop-Layout.

### 1.2 State Management & Routing
- **Provider** für Dependency Injection und ChangeNotifier-basierten State
  (`lib/config/dependencies.dart`).
- **GoRouter** für die Navigation, Admin-Routen sind über `AdminGuard` durch
  Login + Rolle geschützt (`lib/UI/web/admin/admin_router.dart`).

### 1.3 Backend (Supabase)
- Authentifizierung, Postgres-Datenbank, Storage und RPCs liefert Supabase.
- Datenbankänderungen liegen unter `terraform-supabase/` und in
  `supabase/migrations/*.sql`. **Wichtig**: Provisionierung läuft aktuell
  nicht über `terraform apply`, sondern über `supabase db push` (siehe
  Memory-Eintrag `terraform_broken.md`).

### 1.4 Verzeichnis-Layout (Auszug)
```
lib/
├── UI/
│   ├── mobile/           # Kunden-App
│   └── web/admin/        # Admin-Dashboard (diese Roadmap)
│       ├── admin_router.dart
│       ├── analytics/
│       ├── commission_management/
│       ├── dashboard/
│       ├── order_management/
│       ├── route_management/
│       ├── team_management/
│       └── whisky_catalog/
├── data/
│   ├── providers/        # ChangeNotifier State-Container
│   ├── repositories/
│   └── services/
└── domain/models/        # Freezed-Datenmodelle
```

---

## 2. Status pro Phase

| Phase | Thema                              | Status |
| ----- | ---------------------------------- | ------ |
| 1     | Web-Setup & Responsive Design      | ✅ Abgeschlossen |
| 2     | Admin-Dashboard & RBAC             | ✅ Abgeschlossen |
| 3     | Wanderrouten-Verwaltung            | 🔄 ~85 % (Karten-Tooling ausstehend) |
| 4     | Bestellverwaltung & Fulfillment    | ✅ Abgeschlossen |
| 5     | Whisky-Katalog & Tasting-Sets      | ✅ Abgeschlossen |
| 6     | Provisionen & Abrechnung           | ✅ Abgeschlossen |
| 7     | Analytics & Reporting              | 🔄 ~75 % (View-Tracking ausstehend) |
| 8     | Benutzer- & Team-Management        | 🔄 ~40 % (Feinrollen + Audit ausstehend) |
| 9     | Externe Integrationen              | 🔄 Geplant |
| 10    | Testing & Deployment               | 🔄 Laufend |

Detailerklärungen pro Phase folgen in Kapitel 3.

---

## 3. Phasen im Detail

### Phase 1 – Web-Setup & Responsive Design ✅
- `flutter config --enable-web` aktiviert, Web-Plattform in `pubspec.yaml`
  und Build-Artefakten verfügbar.
- Responsive Layouts für Mobile, Tablet und Desktop, geteilt über
  `responsive_layout.dart` und plattform-spezifische Pages.
- Admin-Routen im GoRouter (`admin_router.dart`):
  `/admin/dashboard`, `/admin/routes`, `/admin/orders`, `/admin/whisky`,
  `/admin/finances`, `/admin/analytics`, `/admin/team`.

### Phase 2 – Admin-Dashboard & RBAC ✅
**Dashboard**: `DashboardMetricsService` + `DashboardProvider` liefern
Umsatz, Bestellungen, Top-Routen, Ratings, Wachstum. UI: KPI-Cards, Recent
Orders, Popular Routes, Wachstums-Indikatoren.

**RBAC (Mai 2026)**:
- `profiles.role` (`'user' | 'admin'`) mit CHECK-Constraint und
  Default-Trigger (`handle_new_user`).
- `public.is_admin(uid)` als SECURITY DEFINER für RLS.
- RLS-Policies auf `hikes`, `waypoints`, `hikes_waypoints`, `hike_images`,
  `tasting_sets`, `whisky_samples`, `companies`, `*_shipping_rules`, sowie
  Storage-Bucket `hike-images` auf `is_admin()` umgestellt.
- `enforce_profile_role_change`-Trigger verhindert Self-Promotion.
- `public.set_user_role(uuid, text)` (SECURITY DEFINER) für Admin-UI.
- Flutter: `AuthService.isCurrentUserAdmin()`, `AdminGuard`,
  `AdminRouteGuard` (async Redirect).

Offen: Feinrollen Manager/Staff/Viewer (siehe Phase 8).

### Phase 3 – Wanderrouten-Verwaltung 🔄
**Service & Provider**: `RouteManagementService` (CRUD für Routen +
Wegpunkte), `RouteManagementProvider` (Filter, Sortierung, Reihenfolge).

**UI**: Responsive Page mit Drag-&-Drop für Wegpunkte, Distance-Berechnung,
Status-Management. Wegpunkt-Bilder via Service-Layer.

**Noch offen**:
- Vollwertige Karten-Integration (OpenStreetMap) inkl. Klick-Eingabe für
  Koordinaten.
- Preisgestaltung und Galerie-Bilder pro Route.
- Saisonale Verfügbarkeit.

### Phase 4 – Bestellverwaltung & Fulfillment ✅
- `OrderManagementService` (CRUD, Status-Workflow pending → confirmed →
  processing → shipped → delivered).
- `OrderManagementProvider` (Filter nach Status/Datum/Betrag/Kunde,
  Sortierung, Volltext-Suche).
- UI: `OrderManagementPage`, `OrderListWidget` (Tabelle Desktop, Cards
  Mobile), `OrderFilterWidget`, `OrderStatisticsWidget`, `OrderStatusChip`,
  `OrderDetailsDialog`.

Tests: 16 Service + 31 Provider + Widget-Tests.

Offen: Versandetiketten, externe Versand-APIs (siehe Phase 9).

### Phase 5 – Whisky-Katalog & Tasting-Sets ✅
- `TastingSet` + `WhiskySample` als Freezed-Modelle, 1:1-Relation Hike →
  TastingSet, `price = 0.0` (im Hike-Preis enthalten).
- `WhiskyManagementService`: CRUD + Image-Upload (Supabase Storage).
- `WhiskyManagementProvider`: Filter (Region, Brennerei), Sortierung,
  Suche, Statistiken.
- UI: `WhiskyCatalogPage`, `TastingSetCard`, `TastingSetList`, Filter,
  Details-Dialog.

Tests: 32 Provider-Tests, vollständig grün.

### Phase 6 – Provisionen & Abrechnung ✅
**Foundation**:
- `Commission` (Freezed) mit Status `pending → calculated → paid →
  cancelled`, Validierung der Rate (0–100 %), Business-Logik-Extensions
  (Overdue-Erkennung, Formatierung).
- `CommissionService`: CRUD + Statistiken (Total, Pending, Paid, Average
  Rate), Date-Range-Queries, Batch-Operationen.

**UI** (`/admin/finances`):
- `CommissionProvider` (State + Filter).
- Widgets: `CommissionStatusChip`, `CommissionFilterWidget`,
  `CommissionStatisticsWidget`, `CommissionListWidget`,
  `CommissionDetailsDialog`, `CommissionStatisticsWithChartsWidget`.
- Charts: Timeline, Status-Distribution, By-Hike (via `fl_chart`).
- Export: `CommissionExportService` + `CommissionExportWidget` (PDF, CSV;
  Browser-Download via `dart:html`).
- Automatik: `EnhancedOrderWorkflowWithCommission` erzeugt beim
  Status-Übergang `delivered` automatisch Provisionseinträge.

Tests: 41 Foundation + 18 Provider + 14 Integration + Widget-Tests.

### Phase 7 – Analytics & Reporting 🔄 (~75 %)
**Domain-Modelle**: `SalesStatistics`, `RoutePerformance`,
`CustomerInsights`, `PerformanceMetrics` – jeweils mit Extensions
(Formatierung, Grades, Top-Listen). 78 Model-Tests.

**Services**:
- `SalesAnalyticsService`: Aggregation von Orders nach Datum/Route/Company,
  Top-Routen, Route-Performance inkl. Reviews.
- `CustomerAnalyticsService`: Acquisition, Retention, LTV, Geographic
  Distribution, Segmentation (high/medium/low), Churn-Risiko (>90 Tage
  inaktiv).
- 25 Service-Tests.

**Provider & UI** (`/admin/analytics`):
- `AnalyticsProvider` lädt parallel Sales, Customer, TopRoutes,
  Segmentation, Churn; Date-Range-Filter und Company-Filter; 5
  Provider-Tests.
- Page mit Toolbar (Date-Range-Picker + 7/30/90/365-Tage-Presets),
  4 KPI-Karten, Revenue-Timeline (LineChart), Customer-Stats,
  Top-Routes-Liste.

**Export & Charts (neu, Mai 2026)**:
- `AnalyticsExportService` (Mai 2026) erzeugt PDF-Berichte (Sales,
  Customer, Top-Routes, Tages-Timeline) sowie CSVs für Revenue-Timeline
  und Route-Aufschlüsselung; sanitisierte Dateinamen mit Zeitstempel.
- `AnalyticsExportButton` in der AppBar mit PDF / Timeline-CSV /
  Routes-CSV.
- Neue Charts auf der Analytics-Page: Bar-Chart `Umsatz je Route`,
  Pie-Chart `Kundensegmentierung` inkl. Churn-Hinweis.
- 9 neue Tests für `AnalyticsExportService` (PDF-Magic-Header,
  Argument-Validierung, CSV-Inhalte, Filename-Sanitisierung).

**Noch offen**:
- Echtes View-Tracking via `analytics_events`-Tabelle. Aktuell wird die
  Conversion-Rate aus einer 4:1-Heuristik auf Basis der Bestellungen
  berechnet (siehe TODO in `SalesAnalyticsService.getRoutePerformance`).
- `PerformanceMetrics`-Modell in den Provider/UI einbinden (aktuell nur
  Modell + Tests).

### Phase 8 – Benutzer- & Team-Management 🔄
**Aktuell**:
- DB: `set_user_role(uuid, text)` (SECURITY DEFINER), Self-Demotion
  serverseitig blockiert.
- `TeamManagementService` + `TeamProvider`: Profile listen (Filter nach
  Rolle, Suche nach Name/E-Mail), Promote/Demote.
- UI `/admin/team`: Responsive (DataTable ab 900 px, Karten-Liste darunter)
  inkl. Confirmation-Dialog.
- 7 Provider-Tests.

**Noch offen**:
- Invite-Flow (E-Mail + Initial-Rolle).
- Feinrollen `manager`, `staff`, `viewer` inkl. differenzierter RLS und
  `has_role(text)`-Helper.
- Audit-Logs (Schritt 9.2).

### Phase 9 – Externe Integrationen 🔄
Geplant:
- Stripe Webhooks für Payment-Status (Order Tracking).
- Versand-APIs (DHL, Deutsche Post) für Labels und Tracking-Updates.
- Aktivitäts-Tabelle für Audit (`activity_logs`).

### Phase 10 – Testing & Deployment 🔄
- Unit-, Provider- und Widget-Tests bereits flächendeckend.
- Web-Build: `flutter build web --no-tree-shake-icons` (langsam – im CI
  läuft das in einem dedizierten Job).
- Deployment-Pipeline und CDN-Konfiguration sind noch nicht final.

---

## 4. Test-Übersicht

| Bereich               | Tests | Status |
| --------------------- | ----: | ------ |
| Dashboard             |    44 | ✅ |
| Route-Management      |    *  | ✅ |
| Order-Management      |   47+ | ✅ |
| Whisky-Katalog        |    32 | ✅ |
| Commission Foundation |    41 | ✅ |
| Commission Provider/UI|   22+ | ✅ |
| Analytics Modelle     |    78 | ✅ |
| Analytics Services    |    25 | ✅ |
| Analytics Provider    |     5 | ✅ |
| Analytics Export      |     9 | ✅ |
| Team-Management       |     7 | ✅ |

`*` Umfassend, aber nicht zentral gezählt.

Gesamt: >390 Tests, Provider-/Service-/Model-Coverage >80 % für alle
abgeschlossenen Phasen.

---

## 5. Aktuelle Prioritäten

1. **Phase 7 finalisieren**:
   - `analytics_events`-Tabelle (Migration + Service-Anbindung) für echte
     Conversion-Tracking.
   - `PerformanceMetrics` aus der Provider/UI ableiten.
2. **Phase 8 Iteration 2**:
   - Invite-Flow für neue Team-Mitglieder.
   - Feinrollen + Audit-Logs.
3. **Phase 3 Vervollständigung**:
   - Karten-basierte Wegpunkt-Eingabe und Galerie-Bilder pro Route.
4. **Phase 9**: Stripe-Webhooks, Versand-APIs.

---

## 6. Wichtige Konventionen

- **Freezed 3.x**: Modelle sind `abstract class`, generiert via
  `flutter pub run build_runner build --delete-conflicting-outputs`.
- **TDD**: Tests werden vor der Implementierung geschrieben; Tests laufen
  schnell, weil Services nach Möglichkeit ohne Supabase-Mocks geprüft
  werden (Business-Logik wird direkt getestet).
- **State-Management**: ChangeNotifier-Provider in `lib/data/providers/`,
  Provider werden zentral in `lib/config/dependencies.dart` registriert.
- **Export**: Auf der Web-Plattform erfolgt der Download über
  `dart:html`-Blob (siehe `CommissionExportWidget`,
  `AnalyticsExportButton`). Migration zu `package:web` ist getrackt, aber
  noch nicht erforderlich.
- **Sicherheit**: Sensible Werte (`SUPABASE_URL`, `SUPABASE_ANON_KEY`,
  Stripe-Keys) ausschließlich über `.env` (nicht eingecheckt).

---

## 7. Referenzen

- `CLAUDE.md` – Projektübergreifende Richtlinien (TDD, Freezed-Setup,
  Sicherheits- und Repository-Patterns).
- `WEBAPP_RBAC_IMPLEMENTATION.md` – Vertiefung der RBAC-Architektur.
- `supabase/migrations/20260518120000_admin_role.sql` – RBAC-Migration.
- `supabase/migrations/20260518120100_seed_admin.sql` – Admin-Seed.
