# Offline-First Caching fuer Hike-Daten

Die App verwendet `OfflineFirstHikeRepository` mit `networkFirst`-Strategie fuer Hike-Daten. Der Katalog wird immer zuerst vom Server geladen; der Cache dient nur als Fallback bei schlechter Netzwerkverbindung. Pull-to-Refresh triggert einen `forceRefresh`, der den Cache umgeht.

**Begründung**: User erwarten einen aktuellen Katalog nach langer Inaktivitaet. `networkFirst` garantiert frische Daten beim App-Start, waehrend der Cache Offline-Nutzung moeglich macht. Tab-Switch loest kein Neuladen aus — User ziehen explizit zum Aktualisieren.

### Considered Options
- **Kein Caching (einfaches `HikeRepository`)**: War der vorherige Zustand. Führt dazu, dass Daten nur nach Logout/Login aktualisiert werden, weil `StatefulShellRoute` Tab-State bewahrt.
- **`cacheFirst`**: Waere schnell, aber veraltete Daten nach langer Inaktivitaet waren inakzeptabel.
- **Auto-Refresh beim Tab-Switch**: Wurde abgelehnt — Pull-to-Refresh reicht, Cold Start liefert frische Daten.

### Consequences
- `HikeRepository` wird durch `OfflineFirstHikeRepository` ersetzt.
- `ConnectivityService` muss in `main.dart` initialisiert werden. (Der urspruenglich
  hier genannte `DataSyncService` wurde nie verdrahtet und mit #31 geloescht.)
- `HomePage` bekommt einen `RefreshIndicator` mit `forceRefresh`.
- Der bisherige `OfflineFirstHikeRepository`-Code ist keine tote Infrastruktur mehr.