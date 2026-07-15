# RLS und Rollen aus `profiles` als Autorisierungsgrenze

Status: Akzeptiert

Die Rollen `user` und `admin` werden in `public.profiles.role` gespeichert.
Row Level Security und die `SECURITY DEFINER`-Funktion `public.is_admin()`
setzen diese Rollen fuer geschuetzte Daten und Storage-Operationen durch. Der
`AdminGuard` der Flutter-Oberflaeche ist ausschliesslich eine
Bedienungserleichterung und keine Autorisierungsentscheidung.

Zuvor prueften Policies `auth.users.raw_user_meta_data`; die Migration
`20260518120000_admin_role.sql` verwirft diesen Ansatz, weil Nutzende diese
Metadaten veraendern koennen. Alternativen waeren Rollen in JWT-Claims oder ein
externes IAM-System. Die gewaehlte Variante erlaubt RLS-nahe, nachvollziehbare
Pruefungen ohne Vertrauen in vom Client kontrollierte Daten.

Konsequenz: Neue geschuetzte Tabellen und Storage-Buckets brauchen RLS-Policies
auf Basis von `auth.uid()` und gegebenenfalls `public.is_admin()`. Eine
Erweiterung des Rollenmodells ist eine Schema- und Policy-Migration, nicht nur
eine Anpassung der Admin-Oberflaeche.
