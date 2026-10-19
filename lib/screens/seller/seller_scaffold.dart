import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import 'seller_dashboard_screen.dart';
import 'seller_orders_screen.dart';
import 'menu_management_screen.dart';
import 'seller_settings_screen.dart';

class SellerScaffold extends StatefulWidget {
  const SellerScaffold({super.key});

  @override
  State<SellerScaffold> createState() => _SellerScaffoldState();
}

class _SellerScaffoldState extends State<SellerScaffold> {
  int _currentIndex = 0;
  bool _onboardingChecked = false;
  int _pendingCount = 0;
  StreamSubscription<List<OrderModel>>? _orderSub;

  List<Widget> get _pages => [
        SellerDashboardScreen(
            onSwitchTab: (i) => setState(() => _currentIndex = i)),
        const SellerOrdersScreen(),
        const MenuManagementScreen(),
        const SellerSettingsScreen(),
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderSub?.cancel();
    final uid = context.read<AuthProvider>().currentUserId;
    if (uid.isNotEmpty) {
      _orderSub = DatabaseService().sellerOrdersStream(uid).listen((orders) {
        final count =
            orders.where((o) => o.status == AppConstants.statusPending).length;
        if (mounted && count != _pendingCount) {
          setState(() => _pendingCount = count);
        }
      });
    }
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  void _showSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Up Your Stall'),
        content: const Text(
          'Complete your stall profile so customers can find you — add your stall name, cuisine type, and operating hours.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Set Up Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AuthProvider>().seller;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    if (!_onboardingChecked && seller != null && seller.stallName.isEmpty) {
      _onboardingChecked = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showSetupDialog(context));
    }

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: true,
                    minExtendedWidth: 224,
                    backgroundColor: Colors.white,
                    selectedIndex: _currentIndex,
                    indicatorColor: AppColors.primary.withValues(alpha: 0.1),
                    selectedIconTheme:
                        const IconThemeData(color: AppColors.primary),
                    unselectedIconTheme:
                        const IconThemeData(color: AppColors.textSecondary),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    onDestinationSelected: (index) =>
                        setState(() => _currentIndex = index),
                    leading: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Row(
                        children: [
                          Icon(Icons.storefront_outlined,
                              color: AppColors.primary, size: 26),
                          SizedBox(width: 12),
                          Text(
                            'Seller Hub',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    destinations: [
                      const NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: _PendingOrdersIcon(count: _pendingCount),
                        selectedIcon: _PendingOrdersIcon(
                          count: _pendingCount,
                          active: true,
                        ),
                        label: const Text('Orders'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        selectedIcon: Icon(Icons.restaurant_menu),
                        label: Text('Menu'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 62,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Dashboard',
                        index: 0,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        label: 'Orders',
                        index: 1,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                        badgeCount: _pendingCount,
                      ),
                      _NavItem(
                        icon: Icons.restaurant_menu_outlined,
                        activeIcon: Icons.restaurant_menu,
                        label: 'Menu',
                        index: 2,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        label: 'Settings',
                        index: 3,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _PendingOrdersIcon extends StatelessWidget {
  final int count;
  final bool active;

  const _PendingOrdersIcon({required this.count, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.receipt_long : Icons.receipt_long_outlined),
        if (count > 0)
          Positioned(
            top: -7,
            right: -10,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.textHint,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
