import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double? growthPercentage;
  final IconData icon;
  final Color color;

  const KpiCard({
    Key? key,
    required this.title,
    required this.value,
    this.growthPercentage,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          if (growthPercentage != null) ...[
            SizedBox(height: 4),
            _buildGrowthIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildGrowthIndicator() {
    final isPositive = growthPercentage! >= 0;
    final formattedPercentage =
        '${isPositive ? '+' : ''}${growthPercentage!.toStringAsFixed(1)}%';

    return Row(
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 12,
          color: isPositive ? Colors.green[600] : Colors.red[600],
        ),
        SizedBox(width: 2),
        Text(
          formattedPercentage,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isPositive ? Colors.green[600] : Colors.red[600],
          ),
        ),
      ],
    );
  }
}
