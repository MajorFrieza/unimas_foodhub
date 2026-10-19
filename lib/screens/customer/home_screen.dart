import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_model.dart';
import '../../models/seller_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSwitchToSearch;
  const HomeScreen({super.key, this.onSwitchToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  String _selectedCuisine = 'All';

  static const _cuisines = ['All', 'Malay', 'Chinese', 'Indian', 'Western', 'Japanese'];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showNotifications(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(userId: userId, db: _db),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.customer?.name ?? auth.seller?.stallName ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showNotifications(context, auth.currentUserId),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    GestureDetector(
                      onTap: () => widget.onSwitchToSearch?.call(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: const Row(
                          children: [
                            Icon(Icons.search,
                                color: AppColors.textHint, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Search restaurants or food...',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cuisine filter pills
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _cuisines.map((c) {
                      final selected = c == _selectedCuisine;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCuisine = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // My Favourites (only shown when the customer has saved stalls)
            SliverToBoxAdapter(
              child: StreamBuilder<List<String>>(
                stream: _db.favouriteStallIdsStream(auth.currentUserId),
                builder: (context, favSnap) {
                  final favIds = favSnap.data ?? [];
                  if (favIds.isEmpty) return const SizedBox.shrink();
                  return StreamBuilder<List<SellerModel>>(
                    stream: _db.sellersStream(),
                    builder: (context, sellerSnap) {
                      final favSellers = (sellerSnap.data ?? [])
                          .where((s) => favIds.contains(s.uid))
                          .toList();
                      if (favSellers.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              'My Favourites',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 116,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: favSellers.length,
                              itemBuilder: (context, i) => _FavouriteStallCard(
                                seller: favSellers[i],
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/customer/menu',
                                  arguments: favSellers[i],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Popular Right Now
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Right Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onSwitchToSearch?.call(),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text(
                        'See all ›',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: StreamBuilder<List<MenuItemModel>>(
                stream: _db.allMenuItemsStream(),
                builder: (context, snap) {
                  final all = snap.data ?? [];
                  final popular = all
                      .where((i) => i.isAvailable)
                      .take(6)
                      .toList();
                  if (popular.isEmpty) {
                    return const SizedBox(height: 120);
                  }
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popular.length,
                      itemBuilder: (context, i) {
                        final item = popular[i];
                        return _PopularItemCard(
                          item: item,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/customer/item',
                            arguments: item,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // All Restaurants
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: StreamBuilder<List<SellerModel>>(
                  stream: _db.sellersStream(),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Restaurants',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$count places',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            StreamBuilder<List<SellerModel>>(
              stream: _db.sellersStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    ),
                  );
                }
                var sellers = snap.data ?? [];
                if (_selectedCuisine != 'All') {
                  sellers = sellers
                      .where((s) => s.cuisineType == _selectedCuisine)
                      .toList();
                }
                if (sellers.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No restaurants found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final seller = sellers[i];
                      return _RestaurantCard(
                        seller: seller,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/customer/menu',
                          arguments: seller,
                        ),
                      );
                    },
                    childCount: sellers.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _PopularItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const _PopularItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: ImageHelper.buildImage(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: _placeholder(),
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.fastfood_outlined,
            color: AppColors.primary, size: 32),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onTap;

  const _RestaurantCard({required this.seller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageHelper.buildImage(
                      seller.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: _imgPlaceholder(),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                    // Open/Closed badge bottom-left
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: seller.isEffectivelyOpen
                              ? AppColors.success
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              seller.openStatusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.stallName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.popular.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 12, color: AppColors.popular),
                            const SizedBox(width: 3),
                            Text(
                              seller.rating > 0
                                  ? seller.rating.toStringAsFixed(1)
                                  : 'New',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                        seller.cuisineType,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                      if (seller.location != null &&
                          seller.location!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Text('•',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            seller.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (seller.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      seller.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.storefront_outlined,
              color: AppColors.primary, size: 40),
        ),
      );
}

class _FavouriteStallCard extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onTap;

  const _FavouriteStallCard({required this.seller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 68,
                width: double.infinity,
                child: ImageHelper.buildImage(
                    seller.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: _placeholder(),
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.stallName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: seller.isEffectivelyOpen ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        seller.isEffectivelyOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 10,
                          color: seller.isEffectivelyOpen ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.storefront_outlined, color: AppColors.primary, size: 26),
        ),
      );
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────

class _NotificationsSheet extends StatelessWidget {
  final String userId;
  final DatabaseService db;

  const _NotificationsSheet({required this.userId, required this.db});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle + title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Text(
                      'Order Updates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order list
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: db.customerOrdersStream(userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                final orders = snap.data ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_outlined,
                            size: 48, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text(
                          'No order updates yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 20, endIndent: 20),
                  itemBuilder: (context, i) =>
                      _NotificationTile(order: orders[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final OrderModel order;
  const _NotificationTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(order.status);
    final time = DateFormat('d MMM, h:mm a').format(order.createdAt);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: info.$1.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(info.$2, color: info.$1, size: 20),
      ),
      title: Text(
        info.$3,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            '${order.stallName} • Order #${order.id.replaceAll('-', '').substring(0, 6).toUpperCase()}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            time,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _statusInfo(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return (AppColors.statusPending, Icons.hourglass_top_outlined,
            'Order received — waiting for confirmation');
      case AppConstants.statusConfirmed:
        return (AppColors.info, Icons.check_circle_outline,
            'Order confirmed by stall');
      case AppConstants.statusPreparing:
        return (AppColors.statusPreparing, Icons.soup_kitchen_outlined,
            'Your order is being prepared');
      case AppConstants.statusReady:
        return (AppColors.statusReady, Icons.done_all,
            'Order ready — please collect!');
      case AppConstants.statusCompleted:
        return (AppColors.success, Icons.check_circle,
            'Order completed. Enjoy your meal!');
      default:
        return (AppColors.error, Icons.cancel_outlined,
            'Order was cancelled');
    }
  }
}
