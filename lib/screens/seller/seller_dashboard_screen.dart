import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class SellerDashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onSwitchTab;
  const SellerDashboardScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final seller = auth.seller;
    final db = DatabaseService();

    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: db.sellerOrdersStream(auth.currentUserId),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            final today = DateTime.now();
            final todayOrders = orders.where((o) {
              return o.createdAt.year == today.year &&
                  o.createdAt.month == today.month &&
                  o.createdAt.day == today.day;
            }).toList();
            final revenue = todayOrders.fold<double>(
                0, (sum, o) => sum + o.totalAmount);
            return CustomScrollView(
              slivers: [
                // Header + Stats (combined with rounded bottom)
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        // Greeting + toggle
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    seller?.stallName ?? 'My Stall',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _OpenToggle(
                              isOpen: seller?.isOpen ?? false,
                              onToggle: (val) async {
                                await db.updateSellerIsOpen(
                                    auth.currentUserId, val);
                                auth.updateSellerOpenStatus(val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats grid — white cards
                        Builder(builder: (_) {
                          final activeOrders = orders
                              .where((o) =>
                                  o.status != AppConstants.statusCompleted &&
                                  o.status != AppConstants.statusCancelled)
                              .length;
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.6,
                            children: [
                              _StatCard(
                                icon: Icons.receipt_long_outlined,
                                value: '${todayOrders.length}',
                                label: "Today's Orders",
                              ),
                              _StatCard(
                                icon: Icons.trending_up,
                                value: 'RM ${revenue.toStringAsFixed(0)}',
                                label: 'Revenue',
                              ),
                              _StatCard(
                                icon: Icons.pending_actions_outlined,
                                value: '$activeOrders',
                                label: 'Active Orders',
                              ),
                              _StatCard(
                                icon: Icons.star_outline,
                                value: seller?.rating != null && seller!.rating > 0
                                    ? seller.rating.toStringAsFixed(1)
                                    : '—',
                                label: 'Rating',
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Quick Actions
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_circle_outline,
                            label: 'Add Food Item',
                            onTap: () => Navigator.pushNamed(
                                context, '/seller/menu/add'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.restaurant_menu_outlined,
                            label: 'View Menu',
                            onTap: () => onSwitchTab?.call(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Orders
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Orders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onSwitchTab?.call(1),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View all ›',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                orders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No orders yet',
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final order = orders[i];
                            return _RecentOrderTile(
                              order: order,
                              onUpdateStatus: (status) async {
                                await db.updateOrderStatus(
                                    order.id, status);
                              },
                            );
                          },
                          childCount: orders.take(5).length,
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OpenToggle extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onToggle;

  const _OpenToggle({required this.isOpen, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isOpen),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOpen ? AppColors.success : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOpen ? Colors.white : Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOpen ? 'Open' : 'Closed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<String> onUpdateStatus;

  const _RecentOrderTile(
      {required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                      '#${order.id.replaceAll('-', '').substring(0, 6).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.items
                      .map((i) => i.name)
                      .take(2)
                      .join(', '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(order.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (_nextStatus(order.status) != null)
                const SizedBox(height: 6),
              if (_nextStatus(order.status) != null)
                GestureDetector(
                  onTap: () => onUpdateStatus(_nextStatus(order.status)!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _nextLabel(order.status)!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
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
        return 'Confirm';
      case AppConstants.statusConfirmed:
        return 'Preparing';
      case AppConstants.statusPreparing:
        return 'Ready';
      case AppConstants.statusReady:
        return 'Complete';
      default:
        return null;
    }
  }
}
