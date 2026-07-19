# Supabase-CLI-Migrationen als Schemaautoritaet

Status: Akzeptiert

Die zeitgestempelten Dateien unter `terraform-supabase/supabase/migrations/`
sind die kanonische, vorwaertskompatible Schemahistorie. Terraform provisioniert
das Supabase-Projekt und zugehoerige Infrastruktur, soll aber keine zweite,
parallel gepflegte Datenbankhistorie etablieren. Bereits ausgerollte Migrationen
werden nicht nachtraeglich editiert.

Als Alternativen bestehen im Repository Terraform-`local-exec`-Aufrufe mit
`terraform-supabase/sql/`, Root-SQL-Dateien und manuelle Dashboard-Aenderungen.
Diese Pfade koennen Schema, RLS, Trigger und App-Annahmen auseinanderlaufen
lassen. Eine eindeutige Migrationshistorie ist fuer reproduzierbare Staging- und
Produktionsumgebungen wichtiger als die kurzfristige Bequemlichkeit einzelner
SQL-Skripte.

Konsequenz: Neue Schemaversionen entstehen als Supabase-CLI-Migrationen,
einschliesslich RLS, Indizes, Triggern und Storage-Policies. Die bestehenden
Terraform-SQL-Deployments sind bekannte technische Schuld und duerfen nicht als
zusaetzliche Quelle neuer Schemaversionen verwendet werden, bevor sie auf den
kanonischen Ablauf umgestellt oder entfernt sind.

**Nachtrag (2026-07-19, #67):** Der Spiegelbaum `terraform-supabase/sql/` wurde
entfernt. Jede seiner 16 Dateien hatte eine Entsprechung unter
`supabase/migrations/`, mit einer Ausnahme: das Vault-Setup lebt jetzt als
`20260719120000_supabase_vault_stripe_secrets.sql`. Der Baum darf nicht wieder
angelegt werden — eine zweite Schemawahrheit ist genau das, was dieses ADR
ausschliesst. Neue SQL-Dateien gehoeren als datierte Migration nach
`terraform-supabase/supabase/migrations/`.
