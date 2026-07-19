# Architekturentscheidungen

Dieses Verzeichnis dokumentiert Entscheidungen, die aus dem vorhandenen Code
und der technischen Dokumentation abgeleitet wurden. ADRs beschreiben den
beabsichtigten, langfristigen Architekturrahmen; bekannte Abweichungen im
Bestand stehen jeweils bei den Konsequenzen.

| ADR | Entscheidung | Status |
| --- | --- | --- |
| [0001](0001-supabase-as-backend-platform.md) | Supabase als Backend-Plattform | Akzeptiert |
| [0002](0002-rls-and-profile-roles-for-authorization.md) | RLS und Rollen aus `profiles` als Autorisierungsgrenze | Akzeptiert |
| [0003](0003-supabase-cli-migrations-as-schema-authority.md) | Supabase-CLI-Migrationen als Schemaautoritaet | Akzeptiert |
| [0004](0004-provider-repository-service-architecture.md) | Provider, Repositories und Services als App-Architektur | Akzeptiert |
| [0005](0005-tasting-set-included-with-hike.md) | Tasting-Set ist Bestandteil eines Hikes | Akzeptiert |
| [0006](0006-server-side-stripe-payment-intents.md) | Stripe Payment Intents ausschliesslich serverseitig erzeugen | Akzeptiert |
| [0007](0007-ci-smoke-gate-during-test-suite-recovery.md) | CI-Smoke-Gate waehrend der Test-Bereinigung | Akzeptiert, befristet |
| [0008](0008-offline-first-hike-caching.md) | Offline-First-Hike-Caching | Akzeptiert |
| [0009](0009-split-profile-avatar-account-concepts.md) | Profile, Avatar und Account als getrennte Domaenenkonzepte | Akzeptiert |
| [0010](0010-profiles-email-as-denormalized-projection.md) | `profiles.email` als denormalisierte Projektion per Trigger synchronisiert | Akzeptiert |
| [0011](0011-server-side-entitlements-purchased-hikes.md) | `purchased_hikes`-Entitlements werden nur serverseitig geschrieben | Akzeptiert |
| [0012](0012-purchase-read-module-and-row-port.md) | Purchase-Lesemodul getrennt vom Intake, Port spricht Rows | Akzeptiert |

Neue ADRs erhalten fortlaufende vierstellige Nummern. Sie werden nur fuer
schwer rueckgaengig zu machende Entscheidungen mit relevanten Alternativen
angelegt.
