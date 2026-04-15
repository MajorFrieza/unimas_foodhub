import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/order_status_chip.dart';
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final _db = DatabaseService();
  int _selectedTab = 0; // 0 = Active orders, 1 = History

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final seller = authProvider.seller;
    if (seller == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(seller.stallName),
        backgroundColor: AppColors.primaryDark,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Menu',
            onPressed: () =>
                Navigator.of(context).pushNamed('/seller/menu'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stall open/close toggle
          Container(
            color: AppColors.primaryDark,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.isOpen ? 'Stall is Open' : 'Stall is Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        seller.isOpen
                            ? 'Customers can place orders'
                            : 'Toggle to start accepting orders',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: seller.isOpen,
                  onChanged: (v) => _toggleOpen(v, authProvider),
                  activeThumbColor: AppColors.success,
                  inactiveThumbColor: Colors.white60,
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _TabButton(
                  label: 'Active Orders',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: 'History',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _db.sellerOrdersStream(seller.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryDark),
                  );
                }

                final allOrders = snapshot.data ?? [];

                final activeStatuses = {
                  AppConstants.statusPending,
                  AppConstants.statusPreparing,
                  AppConstants.statusReady,
                };

                final orders = _selectedTab == 0
                    ? allOrders
                        .where((o) => activeStatuses.contains(o.status))
                        .toList()
                    : allOrders
                        .where((o) =>
                            o.status == AppConstants.statusCompleted ||
                            o.status == AppConstants.statusCancelled)
                        .toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          _selectedTab == 0
                              ? 'No active orders'
                              : 'No past orders',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) => _SellerOrderCard(
                    order: orders[i],
                    onStatusUpdate: (newStatus) =>
                        _updateStatus(orders[i].id, newStatus),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleOpen(bool isOpen, AuthProvider authProvider) async {
    await _db.updateSellerIsOpen(authProvider.currentUserId, isOpen);
    authProvider.updateSellerOpenStatus(isOpen);
  }

  Future<void> _updateStatus(String orderId, String status) async {
    await _db.updateOrderStatus(orderId, status);
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushReplacementNamed('/role-selection');
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primaryDark : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final void Function(String) onStatusUpdate;

  const _SellerOrderCard(
      {required this.order, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('hh:mm a').format(order.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName,
                          style: theme.textTheme.titleMedium),
                      Text(
                        'Code: ${order.pickupCode} · $dateStr',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const Divider(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}×',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.name)),
                      Text('RM ${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_outlined,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.note!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: RM ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                _actionButton(order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String status) {
    if (status == AppConstants.statusPending) {
      return ElevatedButton(
        onPressed: () => onStatusUpdate(AppConstants.statusPreparing),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusPreparing,
          minimumSize: const Size(120, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: const Text('Accept', style: TextStyle(fontSize: 13)),
      );
    }
    if (status == AppConstants.statusPreparing) {
      return ElevatedButton(
        onPressed: () => onStatusUpdate(AppConstants.statusReady),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusReady,
          minimumSize: const Size(120, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: const Text('Mark Ready', style: TextStyle(fontSize: 13)),
      );
    }
    if (status == AppConstants.statusReady) {
      return ElevatedButton(
        onPressed: () => onStatusUpdate(AppConstants.statusCompleted),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusCompleted,
          minimumSize: const Size(120, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: const Text('Collected', style: TextStyle(fontSize: 13)),
      );
    }
    return const SizedBox.shrink();
  }
}
