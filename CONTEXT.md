# Whisky Hikes

Domain context for a guided whisky hiking application. Users purchase hikes, download GPX routes, and consume whisky tastings at waypoints along the route.

## Language

**Hike**:
A guided whisky hike comprising a description, route (GPX), waypoints, and associated whiskies. Listed in a catalog for purchase. Once purchased, the buyer gains access to the full route and tasting pack.
_Avoid_: Wanderung, tour, trek, route

**Hike Status**:
A Hike is either *active* (available for purchase) or *archived* (no longer sold). Archived Hikes are never deleted — purchasers retain access with an "archived" label.
_Avoid_: deleted, removed, disabled, inactive

**Hike Image**:
A photograph illustrating a Hike in the catalog and on its detail screen. Stored as a binary object in Supabase Storage; referenced by a public URL. A Hike has zero or more, in a defined order.
_Avoid_: photo, picture, Bild, gallery image

**Purchase**:
The act of a User buying a Hike. Grants permanent access to the Hike's GPX route and offline whisky tasting pack. A Purchase is created atomically server-side by the `create-payment-intent` Edge Function — order row, Payment Intent, and company/hike validation happen in one transaction. The client never creates an order record directly; it invokes the Edge Function and confirms the Payment Intent via the Stripe SDK. The `PurchaseIntakeRepository` module is the client-side seam for this flow.
_Avoid_: order, booking, reservation, subscription

**Admin**:
A user with the `admin` role who can create, edit, and archive Hikes. Binary role — no intermediate editor or author roles.
_Avoid_: editor, author, manager

**User**:
A person who browses the Hike catalog, purchases Hikes, and accesses purchased content (GPX, tasting packs). Default role.
_Avoid_: customer, buyer, member

**Profile**:
The user's self-curated identity — display name (first, last) and date of birth. Editable by the user on the profile screen. Does not include email, role, or avatar reference.
_Avoid_: account, user record, profil

**Avatar**:
The user's profile image. Stored as a binary object in Supabase Storage; referenced by a public URL. A Profile points to its Avatar by URL. An Avatar may be absent (default placeholder).
_Avoid_: profile picture, profilbild, user image

**Account**:
The user's auth-managed record — email, role, and auth state (signed in / signed out). Email and role live in `auth.users` and `profiles.role`; the app never writes them through the Profile. The Profile screen *displays* Account fields but does not *own* them.
_Avoid_: profile, user, login