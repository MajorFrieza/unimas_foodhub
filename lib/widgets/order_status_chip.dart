import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    final label = _labelFor(status);
    final icon = _iconFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return AppColors.statusPending;
      case AppConstants.statusPreparing:
        return AppColors.statusPreparing;
      case AppConstants.statusReady:
        return AppColors.statusReady;
      case AppConstants.statusCompleted:
        return AppColors.statusCompleted;
      case AppConstants.statusCancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String _labelFor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return 'Pending';
      case AppConstants.statusPreparing:
        return 'Preparing';
      case AppConstants.statusReady:
        return 'Ready for Pickup';
      case AppConstants.statusCompleted:
        return 'Completed';
      case AppConstants.statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _iconFor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Icons.schedule;
      case AppConstants.statusPreparing:
        return Icons.restaurant;
      case AppConstants.statusReady:
        return Icons.check_circle_outline;
      case AppConstants.statusCompleted:
        return Icons.done_all;
      case AppConstants.statusCancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
