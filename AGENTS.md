# AGENTS.md — Whisky Hikes

## Quick Start

```bash
cp .env.example .env          # Required BEFORE flutter pub get (.env is a Flutter asset)
flutter pub get
dart run build_runner build
flutter run
```

Flutter: `>=3.35.1` (CI pins `3.41.7`). Dart SDK: `^3.9.0`.

## Architecture at a Glance

| Layer | Path | Purpose |
| --- | --- | --- |
| Entry (mobile) | `lib/main.dart` | Supabase init, payment init, Provider setup, router |
| Entry (web admin) | `lib/main_web.dart` | Web admin dashboard entry |
| UI (mobile) | `lib/UI/mobile/` | Pages, ViewModels, shared mobile components |
| UI (web) | `lib/UI/web/` | Admin dashboard, guarded by `AdminGuard` per-page |
| UI (shared) | `lib/UI/core/`, `lib/UI/shared/` | Navigation scaffold, common widgets |
| Config | `lib/config/` | Dependencies (`dependencies.dart`), routing, l10n |
| Data | `lib/data/` | Repositories, services (Supabase, payment, cache, offline) |
| Domain | `lib/domain/models/` | Freezed models + generated `.freezed.dart` / `.g.dart` |
| Infra | `terraform-supabase/supabase/` | Migrations + Edge Functions (`supabase db push`) |
| Tests | `test/` | See Testing section |

**State management**: Provider + ChangeNotifier ViewModels. All providers registered in `lib/config/dependencies.dart` (services → repositories → ViewModels order).

**Backend**: Supabase (`BackendApiService` centralizes all calls). Payment: `MultiPaymentService` (Stripe, Apple Pay, Google Pay) — singleton, initialized in `main.dart`.

**Routing**: GoRouter in `lib/config/routing/router.dart`. Route strings in `routes.dart`. Auth redirect auto-redirects unauthenticated users to login.

## Commands

| Command | Purpose |
| --- | --- |
| `flutter pub get` | Install dependencies |
| `dart run build_runner build` | Generate Freezed + JSON + mockito (run after model changes) |
| `dart run build_runner watch` | Watch mode for iterative model editing |
| `flutter analyze` | Static analysis (CI runs this) |
| `dart format --set-exit-if-changed lib/` | Verify formatting (CI gate) |
| `dart format lib/` | Auto-format |
| `flutter gen-l10n` | Regenerate localizations (after ARB edits) |
| `flutter test test/widget_test.dart` | CI smoke test (only green test) |
| `flutter run` | Run mobile app |
| `flutter build apk --debug` | Android debug APK |
| `flutter build ios --debug --no-codesign` | iOS debug (no signing) |
| `flutter build web --target lib/main_web.dart` | Web admin build |

**Order matters**: `.env` must exist → `flutter pub get` → `build_runner` → run/build.

## Freezed Models (Critical)

- **All models must be `abstract class`** (Freezed 3.x requirement).
- `Profile` uses `@unfreezed` (mutable). All other models use `@freezed` (immutable).
- Generated files: `*.freezed.dart`, `*.g.dart` — never hand-edit.
- After any model change: `dart run build_runner build`.

## Environment

`.env` is loaded by `flutter_dotenv` at startup AND bundled as a Flutter asset. Copy from `.env.example`. Required at runtime: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Payment keys (`STRIPE_*`, `APPLE_PAY_*`, `GOOGLE_PAY_*`) are optional — payment service gracefully skips unavailable providers.

**Never commit `.env`** — it's gitignored. Only `.env.example` is tracked.

## Testing

**Only `test/widget_test.dart` passes** (Hike model smoke test). The rest of `test/` has drifted mocks/fixtures and is actively under burn-down.

`test/` is **excluded from `flutter analyze`** in `analysis_options.yaml`. Generated files (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) are also excluded.

When writing new tests, use `test/test_helpers.dart` for test data factories. Mock generation via `@GenerateMocks` in `test/mocks/`.

## Code Style

- 2-space indentation, max 80-char lines
- `dart format` before commits
- Generated files excluded from analysis and formatting
- ViewModels: always use `try-finally` for loading state, depend on repositories (never call services directly)

## Gotchas

- **Two entry points**: `lib/main.dart` (mobile) vs `lib/main_web.dart` (web admin). `flutter build web` must use `--target lib/main_web.dart`.
- **Admin routes** (`/admin/*`) are not auth-guarded at the router level — each page uses `AdminGuard` widget.
- **`pubspec.lock`** is committed (despite `.gitignore` having it commented out, the file is tracked).
- **`build/` and `site/`** are gitignored.
- **Supabase `FileObject`** constructor requires `updatedAt` parameter.
- **Supabase `emailConfirmedAt`** now expects `String` (ISO 8601), not `DateTime`.
