# `purchased_hikes` entitlements are written server-side only

`purchased_hikes` is the entitlement authority of the app: "My Hikes" and every
access check read from it. Until #93 the client could INSERT and DELETE its own
rows — the INSERT policy checked row ownership but no payment, so anyone with
the bundled anon key and their own user JWT could unlock arbitrary hikes for
free via PostgREST. Since migration `20260719130000_purchased_hikes_read_only.sql`
the table is read-only for `anon` and `authenticated` (policies dropped **and**
INSERT/UPDATE/DELETE revoked — without the REVOKE a client DELETE would be a
silent 0-row no-op instead of a hard error). Rows are created and removed
exclusively via `service_role`, i.e. by an Edge Function after confirmed
payment.

**Deliberate regression, decided by the maintainer in #93:** purchases stop
granting entitlements until the server-side settlement path (#57) exists. An
empty "My Hikes" after a paid checkout is the expected state in the interim.
Restoring the client write policies is not a fix; it reopens the hole.

## Considered Options

- **Keep client INSERT, validate payment in the policy** — rejected: an RLS
  policy cannot verify a Stripe payment; any client-reachable write path leaves
  the entitlement decision on untrusted ground (ADR-0002 treats client code as
  untrusted).
- **Wait until #57 exists before closing the hole** — rejected: the free-unlock
  hole weighs heavier than the temporary loss of the purchase path.
- **Policy drop without REVOKE** — rejected: satisfies INSERT rejection but a
  client DELETE would silently affect 0 rows rather than fail, contradicting
  the acceptance criteria of #93.

## Consequences

- `recordHikePurchase` (in `backend_api.dart` and `hike_service.dart`) can
  never succeed again and has no production caller; it is documented as
  dead-by-RLS and awaits the dead-code sweep (#85). Do not wire it back in.
- `HikeService.deleteHike` no longer deletes `purchased_hikes` rows itself;
  the `ON DELETE CASCADE` on `hike_id` covers that when the hike row goes.
- #57 must write entitlements with `service_role` after payment confirmation;
  that is now the only path that fills "My Hikes".
