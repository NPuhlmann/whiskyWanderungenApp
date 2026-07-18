# Split Profile, Avatar, and Account as distinct domain concepts

The `Profile` concept had accumulated three unrelated concerns: user-curated identity (name, date of birth), the avatar image reference (`image_url`), and auth-managed state (email, role). This conflation caused two real bugs: `image_url` was silently stripped on every profile write because it "wasn't a DB field," and `profiles.email` drifted from `auth.users.email` because the app only updated the auth side. We split the domain into **Profile** (identity + avatar URL), **Avatar** (image concept; collapses onto Profile's `imageUrl` field in code), and **Account** (email, role, auth state). The Profile screen composes Profile + Account; admin team-management reads Accounts, not Profiles. `Account` lives on `UserRepository` rather than a dedicated repository, since it is already the auth-adjacent seam.

## Considered Options

- **One Profile model, document as composite** — rejected: keeps the strip-on-write hacks and the email drift; the model lies about ownership.
- **Three Dart models (Profile, Avatar, Account)** — rejected: Avatar is a single URL field; a separate model is over-engineered for a one-screen app. Avatar collapses onto Profile's `imageUrl`.
- **Split Profile from Account, but leave `role` on Profile** — rejected: `CONTEXT.md` would disagree with the code, and the team-management view (which is really an Account list) would keep reading `role` off Profile.

## Consequences

- `Profile` Dart model loses `email` and `role`; a new `Account` model is introduced on `UserRepository`.
- `ProfilePageViewModel` holds both a `Profile` and an `Account`; save splits into a Profile write (ProfileRepository) and an Account email write (UserRepository).
- `team_management_page` and `team_provider` switch from `Profile.role` / `Profile.email` to `Account`.
- `admin_service` orders query (`profiles!inner(email, full_name)`) keeps working — it reads the denormalized `profiles.email` projection (see ADR-0010) and `profiles.first_name`/`last_name`.
