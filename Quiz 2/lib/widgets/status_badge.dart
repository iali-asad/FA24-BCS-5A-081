import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.statusActive;
      case 'under observation':
      case 'observation':
        return AppTheme.statusObservation;
      case 'critical':
        return AppTheme.statusCritical;
      case 'recovered':
        return AppTheme.statusRecovered;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline_rounded;
      case 'under observation':
      case 'observation':
        return Icons.visibility_outlined;
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'recovered':
        return Icons.favorite_border_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
