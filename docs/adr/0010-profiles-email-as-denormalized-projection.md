# Keep `profiles.email` as a denormalized projection synced by trigger

`profiles.email` duplicates `auth.users.email`. We keep the duplicate because admin views (orders dashboard, team-management) need to display user emails, and the `authenticated`/`anon` roles cannot `SELECT` from `auth.users`. Rather than grant admin access to `auth.users` via a SECURITY DEFINER function, we keep the denormalized column and keep it honest: a new `AFTER UPDATE OF email ON auth.users` trigger updates `profiles.email` whenever the source changes. The app stops writing `email` through the Profile — the trigger is the only sync path, so drift is impossible regardless of how the email changes (app, Supabase admin UI, future flows).

## Considered Options

- **Drop the column** — rejected: breaks `admin_service.dart` orders query and `team_management_page`, which rely on `profiles.email` because they can't reach `auth.users.email`. Fixing them requires a SECURITY DEFINER read function and a larger migration than the bug warrants.
- **Keep the column, update from the app on profile save** — rejected: races with auth-side updates and reintroduces drift under a different name. The app only controls one of several paths that change email.

## Consequences

- One new migration adding the `AFTER UPDATE OF email ON auth.users` trigger.
- `BackendApiService.updateUserProfile` keeps stripping `email` from the Profile JSON (the app never writes it).
- A future DBA will see two email columns and ask why — this ADR is the answer.
