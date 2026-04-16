import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order =
        ModalRoute.of(context)!.settings.arguments as OrderModel;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Order #${order.id.substring(0, 6).toUpperCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<OrderModel?>(
        stream: db.orderStream(order.id),
        builder: (context, snap) {
          final current = snap.data ?? order;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stall info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordering from',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current.stallName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status steps card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StatusStep(
                        icon: Icons.receipt_long_outlined,
                        title: 'Order Placed',
                        subtitle: 'Waiting for confirmation',
                        state: _stepState(
                            current.status, AppConstants.statusPending),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusPending)),
                      _StatusStep(
                        icon: Icons.check_circle_outline,
                        title: 'Confirmed',
                        subtitle: 'Stall accepted your order',
                        state: _stepState(
                            current.status, AppConstants.statusConfirmed),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusConfirmed)),
                      _StatusStep(
                        icon: Icons.restaurant_outlined,
                        title: 'Preparing',
                        subtitle: 'Your food is being prepared',
                        state: _stepState(
                            current.status, AppConstants.statusPreparing),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusPreparing)),
                      _StatusStep(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Ready',
                        subtitle: 'Ready for pickup!',
                        state: _stepState(
                            current.status, AppConstants.statusReady),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Estimated time banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.popular.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time,
                            color: AppColors.popular, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${_estimatedTime(current.items)} minutes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order items card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...current.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                'RM ${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'RM ${current.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Back to home button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/customer/home',
                      (route) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  _StepState _stepState(String currentStatus, String stepStatus) {
    final order = [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusReady,
      AppConstants.statusCompleted,
    ];
    final currentIdx = order.indexOf(currentStatus);
    final stepIdx = order.indexOf(stepStatus);
    if (currentIdx > stepIdx) return _StepState.done;
    if (currentIdx == stepIdx) return _StepState.active;
    return _StepState.pending;
  }

  bool _isStepDone(String currentStatus, String stepStatus) {
    return _stepState(currentStatus, stepStatus) == _StepState.done;
  }

  int _estimatedTime(List<OrderItemSnapshot> items) {
    if (items.isEmpty) return 15;
    return 15;
  }
}

enum _StepState { done, active, pending }

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Widget indicator;

    switch (state) {
      case _StepState.done:
        color = AppColors.success;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
        break;
      case _StepState.active:
        color = AppColors.primary;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        );
        break;
      case _StepState.pending:
        color = AppColors.textHint;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.textHint, size: 16),
        );
        break;
    }

    return Row(
      children: [
        indicator,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: state == _StepState.active
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: state == _StepState.pending
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (state == _StepState.done)
          const Icon(Icons.check, color: AppColors.success, size: 18),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool done;
  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        width: 2,
        height: 28,
        color: done ? AppColors.success : AppColors.border,
      ),
    );
  }
}
