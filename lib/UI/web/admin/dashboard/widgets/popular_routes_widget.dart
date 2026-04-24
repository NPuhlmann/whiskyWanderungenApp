import 'package:flutter/material.dart';

class PopularRoutesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> routes;

  const PopularRoutesWidget({Key? key, required this.routes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No popular routes data',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: routes.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final route = routes[index];
        return _RouteListItem(route: route, rank: index + 1, routes: routes);
      },
    );
  }
}

class _RouteListItem extends StatelessWidget {
  final Map<String, dynamic> route;
  final int rank;
  final List<Map<String, dynamic>> routes;

  const _RouteListItem({
    Key? key,
    required this.route,
    required this.rank,
    required this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final salesCount = route['count'] as int? ?? 0;
    final routeName = route['hike_name'] as String? ?? 'Unknown Route';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _getRankColor(rank).withOpacity(0.1),
        child: Text(
          rank.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getRankColor(rank),
          ),
        ),
      ),
      title: Text(
        routeName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.trending_up, size: 14, color: Colors.green[600]),
          SizedBox(width: 4),
          Text(
            '$salesCount sales',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SalesProgressBar(sales: salesCount, maxSales: _getMaxSales()),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 14),
            onPressed: () {
              // Navigate to route details
            },
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return Colors.blue[600]!;
    }
  }

  int _getMaxSales() {
    if (routes.isEmpty) return 1;
    return routes
        .map((r) => r['count'] as int? ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }
}

class _SalesProgressBar extends StatelessWidget {
  final int sales;
  final int maxSales;

  const _SalesProgressBar({
    Key? key,
    required this.sales,
    required this.maxSales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = maxSales > 0 ? sales / maxSales : 0.0;

    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
