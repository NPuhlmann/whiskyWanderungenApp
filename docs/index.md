# Whisky Hikes Entwicklerdokumentation

Whisky Hikes ist eine Flutter-Anwendung fuer kaufbare Whisky-Wanderungen.
Nutzende erwerben eine Wanderroute inklusive Tasting-Set, erhalten das Set per
Versand oder Abholung und werden waehrend der Wanderung zu Tasting-Wegpunkten
gefuehrt. Die Anwendung umfasst ausserdem eine getrennte Flutter-Weboberflaeche
fuer die Administration von Routen, Bestellungen, Whisky und Auswertungen.

Diese Dokumentation beschreibt den im Repository vorhandenen Stand. Sie ist als
Einstieg fuer Entwicklerinnen und Entwickler sowie als technische Referenz fuer
den Betrieb gedacht.

## Schnellzugriff

| Thema | Einstieg |
| --- | --- |
| Lokale App starten | [Einstieg](getting-started.md) |
| Code-Struktur und Datenfluss | [Architektur](architecture.md) |
| Kauf, Karte, Offline und Admin | [App-Flows](features.md) |
| Supabase, Schema und Edge Functions | [Daten und Infrastruktur](backend.md) |
| Codegen, Tests und CI | [Entwicklung](development.md) |
| Secrets, RLS und produktiver Betrieb | [Betrieb und Sicherheit](operations.md) |
| Dauerhafte Architekturentscheidungen | [Architekturentscheidungen](adr/index.md) |

## Systemueberblick

```text
Flutter Mobile App                 Flutter Web Admin
lib/main.dart                      lib/main_web.dart
        |                                  |
        +------ Provider / ChangeNotifier -+
                       |
                Repositories
                       |
             Services und Cache
                       |
     Supabase Auth, Postgres, Storage, Realtime
                       |
       Edge Functions und Stripe (serverseitig)
```

Die mobile Anwendung verwendet `Provider` und `ChangeNotifier` fuer
Abhaengigkeiten und UI-Zustaende, `go_router` fuer Navigation, Freezed-Modelle
fuer die Mehrzahl der Domaenenobjekte und Supabase als Backend. Terraform und
Supabase-Migrationen liegen in `terraform-supabase/`.

## Wesentliche Verzeichnisse

```text
lib/
  config/                 Dependency Injection, Routing, Lifecycle, l10n
  data/                   Repositories, Services und Admin-Provider
  domain/models/          Fachmodelle und deren Erweiterungen
  UI/mobile/              Mobile Nutzeroberflaeche und ViewModels
  UI/web/admin/           Web-Adminoberflaeche
terraform-supabase/       Supabase-Provisioning, SQL und Edge Functions
.github/workflows/        CI- und Release-Workflows
```

## Voraussetzungen

Die CI verwendet Flutter `3.41.7`; das Paket akzeptiert Flutter ab `3.35.1`
und Dart ab `3.9.0`. Fuer die normale App-Entwicklung werden Flutter, ein
Android- oder iOS-Ziel und ein Supabase-Projekt mit einem oeffentlichen Anon
Key benoetigt. Terraform, die Supabase CLI und Node.js sind nur fuer
Infrastrukturarbeiten erforderlich.

Weiter mit [Einstieg](getting-started.md).
