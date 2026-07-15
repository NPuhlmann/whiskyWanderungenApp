# Betrieb und Sicherheit

## Konfiguration und Geheimnisse

Die mobile App liest `.env` zur Laufzeit, die Datei wird aber als Flutter-
Asset gebuendelt. Damit ist sie Bestandteil des Installationspakets und keine
sichere Secret-Ablage.

| Kategorie | Beispiele | Ablage |
| --- | --- | --- |
| Client-Konfiguration | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, Stripe Publishable Key | lokale `.env` bzw. sicherer Client-Konfigurationsweg |
| Operator-Secrets | `SUPABASE_ACCESS_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY` | Secret Store, lokale `terraform.tfvars`, CI-Secrets |
| Stripe-Server-Secrets | `sk_*`, `whsec_*` | Supabase Vault oder anderer serverseitiger Secret Store |
| Release-Signing | Android Keystore, iOS-Zertifikate | GitHub Secrets / CI Secret Store |

!!! danger "Flutter-Bundle ist kein Secret Store"
    `STRIPE_SECRET_KEY_TEST` ist zwar in der aktuellen `.env.example`
    aufgefuehrt und einzelne Dart-Pfade lesen ihn. Ein `sk_*`-Key darf dennoch
    unter keinen Umstaenden in eine Flutter-`.env` oder einen Client-Build
    gelangen. Payment Intents sind ueber die serverseitige Edge Function
    `create-payment-intent` zu erstellen.

## Autorisierung

Die Sicherheitsgrenze liegt im Backend:

1. Row Level Security fuer jede Tabelle aktivieren und testen.
2. Policies anhand von `auth.uid()` und der serverseitigen Admin-Pruefung
   `public.is_admin()` formulieren.
3. Schreiboperationen mit erhoehten Rechten ausschliesslich ueber sichere Edge
   Functions oder vertrauenswuerdige Operator-Tools ausfuehren.
4. `AdminGuard` nur als Bedienkomfort, niemals als Berechtigungsnachweis
   betrachten.

Die Admin-Bootstrap-Migration enthaelt eine hardcodierte E-Mail-Adresse. Vor
einem produktiven oder wiederverwendbaren Deployment muss sie durch
kontrolliertes Provisioning ersetzt werden.

## Plattformberechtigungen

Die App nutzt Standort-, Kamera-, Foto- und teilweise Mikrofonberechtigungen.
Android fordert Fine-, Coarse- und Background-Location an. Vor einem Release
muessen Notwendigkeit, Datenminimierung, Plattformtexte und Consent mit dem
tatsaechlichen Produktumfang abgeglichen werden.

`ios/Runner/Info.plist` erlaubt derzeit beliebige unverschluesselte Loads
ueber `NSAllowsArbitraryLoads = true`. Das muss fuer Produktion entfernt oder
auf eng begrenzte, dokumentierte Ausnahmen reduziert werden.

## Betrieb von Supabase

Vor einem produktiven Rollout pruefen:

| Pruefpunkt | Erwartung |
| --- | --- |
| Schemaquelle | Eine verbindliche Migrationsstrategie fuer Terraform und Supabase CLI |
| RLS | Keine Tabelle oder Storage-Policy ermoeglicht unbeabsichtigten Zugriff |
| Storage | Keine verbliebenen oeffentlichen Policies ohne bewusste Freigabe |
| Edge Functions | Secrets nur serverseitig, Fehler geloggt, Eingaben validiert |
| Stripe | Webhook- und Payment-Status serverseitig verifizieren |
| Backups | Wiederherstellung fuer PostgreSQL und Storage geplant und getestet |
| Monitoring | Supabase-, Edge-Function- und Stripe-Fehler beobachtbar |
| Datenschutz | Standort- und Profildaten nach Zweck und Aufbewahrung dokumentiert |

## Cache und Offline-Betrieb

Gecachte Daten liegen auf dem Endgeraet. Der Profilcache besitzt eine TTL von
24 Stunden, Avatarbilder sieben Tage und maximal 50 MB. Der allgemeine
Offline-Cache besitzt datenabhaengige TTLs und maximal 500 Eintraege je Typ.

Bei Logout, Account-Loeschung oder sicherheitsrelevanten Profilwechseln muss
der zugehoerige Client-Cache geloescht werden. Offline-Schreibvorgaenge und
deren spaetere Synchronisierung sind besonders fuer Waypoints noch vor
Produktion als End-to-End-Ablauf abzusichern.

## Release-Checkliste

1. Flutter-Version mit der CI-Version `3.41.7` abgleichen.
2. `.env` auf clientseitig sichere Variablen pruefen.
3. Codegen, Analyse, Formatierung, Smoke-Test und Plattformbuild ausfuehren.
4. Migrationen in einer Staging-Umgebung anwenden und RLS testen.
5. Payment mit echten serverseitigen Intents und Webhooks in Stripe-Testmodus
   pruefen.
6. Android- und iOS-Berechtigungen sowie Transport-Security pruefen.
7. Release-Signing-Secrets nur im CI-Secret Store verwenden.
8. Nach Deployment Auth, Katalog, Checkout, Tracking, Karte und Adminzugriff
   per Smoke-Test verifizieren.
