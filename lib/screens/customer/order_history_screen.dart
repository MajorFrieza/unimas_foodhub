import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: db.customerOrdersStream(auth.currentUserId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 56, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your order history will appear here',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/customer/search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Start Ordering'),
                  ),
                ],
              ),
            );
          }

          // Active orders first, then past
          final active = orders
              .where((o) =>
                  o.status != AppConstants.statusCompleted &&
                  o.status != AppConstants.statusCancelled)
              .toList();
          final past = orders
              .where((o) =>
                  o.status == AppConstants.statusCompleted ||
                  o.status == AppConstants.statusCancelled)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                _sectionHeader('Active Orders (${active.length})'),
                const SizedBox(height: 8),
                ...active.map((o) => _OrderCard(order: o)),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                _sectionHeader('Past Orders (${past.length})'),
                const SizedBox(height: 8),
                ...past.map((o) => _OrderCard(order: o)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM, h:mm a').format(order.createdAt);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/customer/order-tracking',
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.stallName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''} • Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'RM ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    String label;

    switch (status) {
      case AppConstants.statusPending:
        color = AppColors.statusPending;
        bg = AppColors.statusPending.withValues(alpha: 0.12);
        label = 'Pending';
        break;
      case AppConstants.statusConfirmed:
        color = AppColors.info;
        bg = AppColors.info.withValues(alpha: 0.12);
        label = 'Confirmed';
        break;
      case AppConstants.statusPreparing:
        color = AppColors.statusPreparing;
        bg = AppColors.statusPreparing.withValues(alpha: 0.12);
        label = 'Preparing';
        break;
      case AppConstants.statusReady:
        color = AppColors.statusReady;
        bg = AppColors.statusReady.withValues(alpha: 0.12);
        label = 'Ready';
        break;
      case AppConstants.statusCompleted:
        color = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.12);
        label = 'Completed';
        break;
      default:
        color = AppColors.statusCancelled;
        bg = AppColors.statusCancelled.withValues(alpha: 0.12);
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
