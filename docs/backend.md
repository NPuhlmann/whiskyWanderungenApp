# Daten und Infrastruktur

## Supabase als Backend

Supabase stellt Authentifizierung, PostgreSQL, Storage und Realtime bereit.
Die mobile App initialisiert den Client in `lib/main.dart`; die zentrale
Zugriffs-Fassade ist `lib/data/services/database/backend_api.dart`.

| Bereich | Zentrale Tabellen |
| --- | --- |
| Identitaet | `auth.users`, `profiles` |
| Katalog | `hikes`, `hike_images`, `waypoints`, `hikes_waypoints` |
| Besitz und Fortschritt | `purchased_hikes`, `user_waypoint_visits` |
| Tasting | `tasting_sets`, `whisky_samples` |
| Reviews | `reviews` |
| Basic Commerce | `orders`, `order_items`, `payments` |
| Anbieter und Versand | `companies`, `company_shipping_rules`, `default_shipping_rules` |
| Enhanced Commerce | `enhanced_orders`, `order_status_history`, `shipping_carriers`, `shipping_methods` |

Die kanonischen Supabase-CLI-Migrationen liegen unter
`terraform-supabase/supabase/migrations/`. Zu den wichtigen Einstiegspunkten
gehoeren:

| Datei | Inhalt |
| --- | --- |
| `20250821151237_initial_schema.sql` | Basisschema und grundsaetzliche RLS |
| `20260508120100_companies_system.sql` | Multi-Vendor und Versandregeln |
| `20260508120200_tasting_sets.sql` | Tasting-Sets und Samples |
| `20260508120300_payment_tables.sql` | Orders, Order Items und Payments |
| `20260508120400_enhanced_orders.sql` | Tracking, Historie und Enhanced Orders |
| `20260518120000_admin_role.sql` | Rollenmodell und Admin-Policies |

## Rollen und Row Level Security

`profiles.role` verwendet die Rollen `user` und `admin`. Die Migration
`20260518120000_admin_role.sql` stellt `public.is_admin()` als
`SECURITY DEFINER`-Funktion bereit. Die Admin-Policies fuer Hikes, Waypoints,
Tasting-Sets, Anbieter und Versandregeln nutzen diese Funktion.

Die UI-Pruefung `AdminGuard` ersetzt diese Policies nicht. Jeder neue
Tabellenzugriff muss mit klaren RLS-Policies geplant werden. Client-Code wird
als nicht vertrauenswuerdig behandelt, selbst wenn ein Navigation-Guard
vorhanden ist.

`purchased_hikes` ist seit `20260719130000_purchased_hikes_read_only.sql` fuer
`anon` und `authenticated` read-only (Policies entfernt und Schreibrechte
revoked). Entitlements schreibt ausschliesslich `service_role` — bis das
Settlement (#57) existiert, schaltet ein Kauf bewusst nichts frei (ADR-0011).

## Storage

Die App speichert insbesondere Avatar- und Hike-Bilder in Supabase Storage.
Storage-Regeln liegen in der initialen Migration und in
`20260508120900_storage_policies.sql`. Policies sind additiv; vor Produktion
muss die tatsaechlich ausgerollte Datenbank auf verbliebene oeffentliche
Leseregeln geprueft werden.

## Edge Functions

| Function | Aufgabe |
| --- | --- |
| `calculate-shipping` | Adresse und Anbieter validieren, Versandregeln anwenden und Versandkosten berechnen |
| `create-payment-intent` | Bestellung und Lieferdaten validieren, Stripe-Konfiguration aus Vault lesen, Order/Items erzeugen und Payment Intent anlegen |

Die Funktionen liegen unter `terraform-supabase/supabase/functions/`. Stripe
Secrets gehoeren in Supabase Vault oder eine vergleichbar serverseitige
Secret-Verwaltung. Der Flutter-Client darf ausschliesslich einen Client Secret
fuer die SDK-Bestaetigung erhalten.

## Terraform und weitere SQL-Pfade

`terraform-supabase/main.tf` kann ein Supabase-Projekt erzeugen. Das Schema
kommt ausschliesslich aus `terraform-supabase/supabase/migrations/` und wird mit
`supabase db push` eingespielt (ADR-0003). Der frueher parallel gepflegte Baum
`terraform-supabase/sql/` wurde mit #67 entfernt.

!!! warning "Terraform provisioniert nicht das Schema"
    `terraform apply` ist nicht der Weg, auf dem dieses Projekt aufgesetzt wird.
    Neue Schemaversionen entstehen als datierte Migration, nie als Skript oder
    Dashboard-Aenderung.

### Terraform-Variablen

`terraform-supabase/variables.tf` erwartet unter anderem:

```hcl
organization_id          = "<supabase-organisation>"
database_password        = "<starkes-passwort>"
environment              = "dev"
supabase_access_token    = "<operator-token>"
supabase_service_role_key = "<server-only-key>"
```

Weitere Variablen konfigurieren Stripe-Test- und optional Live-Schluessel.
Alle sensitiven Werte sind nur in einem lokalen, ignorierten
`terraform.tfvars`, in einem Secret Store oder in CI-Secrets abzulegen.

## Migrationsablauf fuer Entwickler

1. Aendere das Schema ausschliesslich in der festgelegten kanonischen
   Migrationsquelle.
2. Lege eine zeitgestempelte, vorwaertskompatible Migration an; aendere keine
   bereits ausgerollten Migrationen.
3. Ergaenze oder pruefe RLS, Indizes, Trigger und Storage-Policies.
4. Passe Domain-Modelle, JSON-Serialisierung, Services und Repositories an.
5. Generiere Freezed-/JSON-Code und fuehre Analyse sowie passende Tests aus.
6. Pruefe den Ablauf mit einem nichtproduktiven Supabase-Projekt.

Eine Datenbankschema-Aenderung ist erst fertig, wenn App-Code und
Infrastruktur dieselben Tabellen-, Spalten- und Policy-Annahmen verwenden.
