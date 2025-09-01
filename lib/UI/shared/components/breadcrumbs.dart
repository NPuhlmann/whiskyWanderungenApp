import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Breadcrumb-Navigation für bessere UX
class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final VoidCallback? onHomeTap;

  const Breadcrumbs({
    super.key,
    required this.items,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Home-Icon
          InkWell(
            onTap: onHomeTap ?? () => context.go('/'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.home,
                size: 20,
                color: Colors.amber[800],
              ),
            ),
          ),
          
          // Separator
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          
          // Breadcrumb-Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLast)
                  // Letztes Item (nicht klickbar)
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  // Klickbare Items
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                
                // Separator (außer beim letzten Item)
                if (!isLast)
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// Einzelnes Breadcrumb-Item
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });
}

/// Breadcrumb-Builder für Admin-Seiten
class AdminBreadcrumbs extends StatelessWidget {
  final String currentSection;
  final String? currentSubsection;

  const AdminBreadcrumbs({
    super.key,
    required this.currentSection,
    this.currentSubsection,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BreadcrumbItem>[
      BreadcrumbItem(
        label: 'Admin',
        onTap: () => context.go('/admin/dashboard'),
      ),
      BreadcrumbItem(
        label: currentSection,
        onTap: null, // Aktuelle Sektion ist nicht klickbar
      ),
    ];

    if (currentSubsection != null) {
      items.add(BreadcrumbItem(
        label: currentSubsection!,
        onTap: null,
      ));
    }

    return Breadcrumbs(
      items: items,
      onHomeTap: () => context.go('/admin/dashboard'),
    );
  }
}
