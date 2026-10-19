import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'customer_profile_screen.dart';

class CustomerScaffold extends StatefulWidget {
  const CustomerScaffold({super.key});

  @override
  State<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends State<CustomerScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomeScreen(onSwitchToSearch: () => setState(() => _currentIndex = 1)),
    const SearchScreen(),
    CartScreen(onBrowse: () => setState(() => _currentIndex = 1)),
    const OrderHistoryScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

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
                          Icon(Icons.restaurant_menu,
                              color: AppColors.primary, size: 26),
                          SizedBox(width: 12),
                          Text(
                            'FoodHub',
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
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.search_outlined),
                        selectedIcon: Icon(Icons.search),
                        label: Text('Search'),
                      ),
                      NavigationRailDestination(
                        icon: _CartNavigationIcon(count: cartCount),
                        selectedIcon: _CartNavigationIcon(
                          count: cartCount,
                          active: true,
                        ),
                        label: const Text('Cart'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long),
                        label: Text('Orders'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth =
                          constraints.maxWidth.clamp(0.0, 1440.0);
                      return Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: contentWidth,
                          height: constraints.maxHeight,
                          child: IndexedStack(
                            index: _currentIndex,
                            children: _pages,
                          ),
                        ),
                      );
                    },
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
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                        index: 0,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.search_outlined,
                        activeIcon: Icons.search,
                        label: 'Search',
                        index: 1,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.shopping_cart_outlined,
                        activeIcon: Icons.shopping_cart,
                        label: 'Cart',
                        index: 2,
                        currentIndex: _currentIndex,
                        badge: cartCount > 0 ? cartCount : null,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        label: 'Orders',
                        index: 3,
                        currentIndex: _currentIndex,
                        onTap: (i) => setState(() => _currentIndex = i),
                      ),
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        index: 4,
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

class _CartNavigationIcon extends StatelessWidget {
  final int count;
  final bool active;

  const _CartNavigationIcon({required this.count, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (count > 0)
          Positioned(
            top: -7,
            right: -10,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
  final int? badge;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge,
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
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
