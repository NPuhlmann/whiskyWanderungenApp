import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/providers/team_provider.dart';
import '../../../../data/services/auth/auth_service.dart';
import '../../../../domain/models/profile.dart';

/// Admin-Seite zur Verwaltung der Team-Rollen (`/admin/team`).
///
/// Zeigt alle Profile in einer Tabelle/Liste, erlaubt Suche + Rollen-Filter
/// und das Promoten zu Admin bzw. das Entziehen der Admin-Rolle. Schreibend
/// läuft alles über `TeamProvider.setUserRole`, das die DB-RPC `set_user_role`
/// aufruft — die endgültige Berechtigungsprüfung passiert serverseitig.
class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team verwalten'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Aktualisieren',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TeamProvider>().load(),
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _Toolbar(
                searchController: _searchController,
                selectedRole: _selectedRole,
                onSearchChanged: provider.setSearchQuery,
                onRoleChanged: (role) {
                  setState(() => _selectedRole = role);
                  provider.setRoleFilter(role);
                },
                adminCount: provider.adminCount,
                userCount: provider.userCount,
              ),
              if (provider.error != null) _ErrorBanner(message: provider.error!),
              Expanded(child: _Body(provider: provider)),
            ],
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedRole;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onRoleChanged;
  final int adminCount;
  final int userCount;

  const _Toolbar({
    required this.searchController,
    required this.selectedRole,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.adminCount,
    required this.userCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Suche nach E-Mail oder Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          DropdownButton<String?>(
            value: selectedRole,
            hint: const Text('Alle Rollen'),
            items: const [
              DropdownMenuItem<String?>(value: null, child: Text('Alle Rollen')),
              DropdownMenuItem<String?>(value: 'admin', child: Text('Nur Admins')),
              DropdownMenuItem<String?>(value: 'user', child: Text('Nur User')),
            ],
            onChanged: onRoleChanged,
          ),
          _CountChip(label: 'Admins', count: adminCount, color: Colors.amber),
          _CountChip(label: 'User', count: userCount, color: Colors.blueGrey),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(label),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: () => context.read<TeamProvider>().clearError(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final TeamProvider provider;
  const _Body({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.profiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.profiles.isEmpty) {
      return const Center(
        child: Text('Keine User gefunden.'),
      );
    }

    final currentUserId = context.read<AuthService>().getCurrentUserId();
    final isWide = MediaQuery.of(context).size.width >= 900;
    return isWide
        ? _TeamTable(profiles: provider.profiles, currentUserId: currentUserId)
        : _TeamList(profiles: provider.profiles, currentUserId: currentUserId);
  }
}

class _TeamTable extends StatelessWidget {
  final List<Profile> profiles;
  final String? currentUserId;

  const _TeamTable({required this.profiles, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('E-Mail')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Rolle')),
          DataColumn(label: Text('Aktion')),
        ],
        rows: profiles.map((p) {
          final name = _formatName(p);
          return DataRow(
            cells: [
              DataCell(Text(p.email)),
              DataCell(Text(name)),
              DataCell(_RoleChip(role: p.role)),
              DataCell(_RoleActionButton(
                profile: p,
                isSelf: p.id == currentUserId,
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  final List<Profile> profiles;
  final String? currentUserId;

  const _TeamList({required this.profiles, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: profiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = profiles[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(_initials(p)),
            ),
            title: Text(p.email),
            subtitle: Text(_formatName(p)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoleChip(role: p.role),
                const SizedBox(width: 8),
                _RoleActionButton(
                  profile: p,
                  isSelf: p.id == currentUserId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Chip(
      label: Text(isAdmin ? 'Admin' : 'User'),
      backgroundColor: isAdmin ? Colors.amber.shade100 : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isAdmin ? Colors.amber.shade900 : Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RoleActionButton extends StatelessWidget {
  final Profile profile;
  final bool isSelf;

  const _RoleActionButton({required this.profile, required this.isSelf});

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == 'admin';
    final tooltip = isSelf && isAdmin
        ? 'Admins können sich nicht selbst herabstufen'
        : null;
    final label = isAdmin ? 'Admin entziehen' : 'Zu Admin machen';
    final onPressed = (isSelf && isAdmin)
        ? null
        : () => _confirmAndApply(context, isAdmin: isAdmin);
    final button = isAdmin
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.remove_moderator, size: 18),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.shield, size: 18),
            label: Text(label),
          );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }

  Future<void> _confirmAndApply(
    BuildContext context, {
    required bool isAdmin,
  }) async {
    final newRole = isAdmin ? 'user' : 'admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdmin ? 'Admin-Rolle entziehen?' : 'Zu Admin machen?'),
        content: Text(
          isAdmin
              ? '${profile.email} wird zu einem normalen User. '
                  'Admin-Zugriff auf /admin/* geht verloren.'
              : '${profile.email} erhält Vollzugriff auf das '
                  'Admin-Dashboard und kann Wanderungen, Bestellungen '
                  'und weitere Admins verwalten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isAdmin ? 'Entziehen' : 'Promoten'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final provider = context.read<TeamProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.setUserRole(userId: profile.id, newRole: newRole);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isAdmin
                ? '${profile.email} ist jetzt User.'
                : '${profile.email} ist jetzt Admin.',
          ),
        ),
      );
    } catch (_) {
      // Fehler wird bereits über den Provider als Banner angezeigt.
    }
  }
}

String _formatName(Profile p) {
  final n = '${p.firstName} ${p.lastName}'.trim();
  return n.isEmpty ? '–' : n;
}

String _initials(Profile p) {
  final first = p.firstName.isNotEmpty ? p.firstName[0] : '';
  final last = p.lastName.isNotEmpty ? p.lastName[0] : '';
  final initials = (first + last).toUpperCase();
  if (initials.isNotEmpty) return initials;
  return p.email.isNotEmpty ? p.email[0].toUpperCase() : '?';
}
