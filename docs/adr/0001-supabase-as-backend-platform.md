# Supabase als Backend-Plattform

Status: Akzeptiert

Die Anwendung verwendet Supabase fuer Authentifizierung, PostgreSQL, Storage
und Realtime. Die Flutter-App initialisiert den Supabase-Client zentral und
greift ueber Services und Repositories darauf zu; Infrastruktur, Edge Functions
und Datenbankschema liegen unter `terraform-supabase/`. Damit werden diese
Backend-Faehigkeiten nicht durch einen separaten, selbst betriebenen API-Server
dupliziert.

Beruecksichtigte Alternativen waren ein eigener Backend-Service mit eigener
Authentifizierung und Storage-Anbindung sowie einzelne SaaS-Dienste je
Fachbereich. Supabase reduziert den Betriebsumfang und liefert PostgreSQL mit
Row Level Security als gemeinsame Daten- und Autorisierungsbasis. Ein spaeterer
Wechsel betrifft die Datenbank, Authentifizierung, Storage-URLs, Policies,
Flutter-Services und Infrastruktur gleichzeitig.

Konsequenz: Die fachliche Autorisierung bleibt in Supabase-RLS und sicheren
serverseitigen Funktionen. Flutter-Code und Navigations-Guards gelten nie als
vertrauenswuerdige Sicherheitsgrenze.
