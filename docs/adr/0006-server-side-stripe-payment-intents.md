# Stripe Payment Intents ausschliesslich serverseitig erzeugen

Status: Akzeptiert

Stripe Secret Keys, Preisvalidierung und die Erzeugung von Payment Intents
bleiben auf dem Server. Die Supabase Edge Function `create-payment-intent`
validiert Bestellung und Lieferdaten, liest Stripe-Konfiguration aus dem Vault
und gibt dem Flutter-Client nur die fuer die SDK-Bestaetigung noetigen Daten,
insbesondere den Client Secret, zurueck. Flutter-`.env` wird als Asset gebuendelt
und darf deshalb nur oeffentliche Konfiguration enthalten.

Alternativen waeren direkte Stripe-REST-Aufrufe aus Flutter, ein eigener
Backend-Service oder Stripe Checkout. Die Edge Function nutzt bereits die
vorhandene Supabase-Infrastruktur und verhindert, dass ein `sk_*`-Key in ein
Client-Bundle oder auf Endgeraete gelangt.

Konsequenz: Der bestehende `StripeBackendService` liest
`STRIPE_SECRET_KEY_TEST` und ruft Stripe direkt aus Flutter auf. Er widerspricht
dieser Entscheidung und darf nicht in produktive Zahlungsablaeufe eingebunden
werden; er ist auf den serverseitigen Pfad umzustellen oder zu entfernen.

**Status (2026-07-17):** Issue #32 schliesst diese Abweichung. `StripeBackendService`
und `StripeService` werden geloescht; ein neues `PurchaseIntakeRepository`
ruft die Edge Function ueber `SupabaseClient.functions.invoke` auf und bestaetigt
den Payment Intent ueber einen `StripeConfirmAdapter` (Production:
`FlutterStripeConfirmAdapter`, Tests: In-Memory-Fake). `STRIPE_SECRET_KEY_TEST`
wird aus `.env.example` entfernt. Die Client-Bundle enthaelt danach nur noch
den Stripe Publishable Key (`pk_*`), wie vom ADR gefordert.
