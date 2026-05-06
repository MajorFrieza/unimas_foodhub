import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: db.sellerOrdersStream(auth.currentUserId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final all = snap.data ?? [];
          final active = all
              .where((o) =>
                  o.status != AppConstants.statusCompleted &&
                  o.status != AppConstants.statusCancelled)
              .toList();
          final past = all
              .where((o) =>
                  o.status == AppConstants.statusCompleted ||
                  o.status == AppConstants.statusCancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrderList(
                orders: active,
                db: db,
                emptyMessage: 'No active orders',
                emptyIcon: Icons.hourglass_empty_outlined,
              ),
              _OrderList(
                orders: past,
                db: db,
                emptyMessage: 'No order history yet',
                emptyIcon: Icons.receipt_long_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final DatabaseService db;
  final String emptyMessage;
  final IconData emptyIcon;

  const _OrderList({
    required this.orders,
    required this.db,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(order: orders[i], db: db),
    );
  }
}

// ─── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final String currentStatus;

  static const _steps = ['New', 'Confirmed', 'Preparing', 'Ready'];
  static const _statuses = [
    AppConstants.statusPending,
    AppConstants.statusConfirmed,
    AppConstants.statusPreparing,
    AppConstants.statusReady,
  ];

  const _StepIndicator({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statuses.indexOf(currentStatus);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final passed = stepIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: passed
                    ? AppColors.primary
                    : AppColors.border,
              ),
            );
          }
          // Step dot
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentIndex;
          final isCurrent = stepIndex == currentIndex;

          return Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.primary
                      : isCurrent
                          ? AppColors.primary
                          : Colors.white,
                  border: Border.all(
                    color: isDone || isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : isCurrent
                        ? const Icon(Icons.circle, size: 8, color: Colors.white)
                        : null,
              ),
              const SizedBox(height: 4),
              Text(
                _steps[stepIndex],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isDone || isCurrent
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final DatabaseService db;

  const _OrderCard({required this.order, required this.db});

  Future<void> _advance(BuildContext context) async {
    final next = _nextStatus(order.status);
    if (next == null) return;

    final label = _nextLabel(order.status)!;
    final confirmed = await _showConfirmDialog(
      context,
      title: label,
      message: _confirmMessage(order.status),
      confirmLabel: label,
      confirmColor: next == AppConstants.statusCompleted
          ? AppColors.accent
          : AppColors.primary,
    );
    if (confirmed == true) {
      await db.updateOrderStatus(order.id, next);
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Cancel Order',
      message:
          'Are you sure you want to cancel this order? The customer will be notified.',
      confirmLabel: 'Yes, Cancel',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await db.updateOrderStatus(order.id, AppConstants.statusCancelled);
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  String _confirmMessage(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return 'Accept this order and notify the customer?';
      case AppConstants.statusConfirmed:
        return 'Start preparing this order now?';
      case AppConstants.statusPreparing:
        return 'Mark this order as ready for pickup?';
      case AppConstants.statusReady:
        return 'Mark this order as completed?';
      default:
        return 'Proceed with this action?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM, h:mm a').format(order.createdAt);
    final next = _nextStatus(order.status);
    final isActive = next != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.replaceAll('-', '').substring(0, 6).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),

          // Step progress (active orders only)
          if (isActive) ...[
            const Divider(height: 1),
            _StepIndicator(currentStatus: order.status),
          ],

          const Divider(height: 1),

          // Items
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
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

                // Rating & comment (completed orders only)
                if (order.status == AppConstants.statusCompleted &&
                    order.rating != null) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < order.rating!
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: i < order.rating!
                                    ? const Color(0xFFFFC107)
                                    : AppColors.border,
                              )),
                      const SizedBox(width: 6),
                      Text(
                        '${order.rating}/5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (order.comment != null &&
                      order.comment!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${order.comment}"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],

                // Action buttons (active orders only)
                if (isActive) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancel(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _advance(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            _nextLabel(order.status)!,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _nextStatus(String current) {
    switch (current) {
      case AppConstants.statusPending:
        return AppConstants.statusConfirmed;
      case AppConstants.statusConfirmed:
        return AppConstants.statusPreparing;
      case AppConstants.statusPreparing:
        return AppConstants.statusReady;
      case AppConstants.statusReady:
        return AppConstants.statusCompleted;
      default:
        return null;
    }
  }

  String? _nextLabel(String current) {
    switch (current) {
      case AppConstants.statusPending:
        return 'Accept Order';
      case AppConstants.statusConfirmed:
        return 'Start Preparing';
      case AppConstants.statusPreparing:
        return 'Mark Ready';
      case AppConstants.statusReady:
        return 'Complete';
      default:
        return null;
    }
  }
}

// ─── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case AppConstants.statusPending:
        color = AppColors.statusPending;
        label = 'New';
        break;
      case AppConstants.statusConfirmed:
        color = AppColors.info;
        label = 'Confirmed';
        break;
      case AppConstants.statusPreparing:
        color = AppColors.statusPreparing;
        label = 'Preparing';
        break;
      case AppConstants.statusReady:
        color = AppColors.statusReady;
        label = 'Ready';
        break;
      case AppConstants.statusCompleted:
        color = AppColors.statusCompleted;
        label = 'Completed';
        break;
      default:
        color = AppColors.error;
        label = 'Cancelled';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
