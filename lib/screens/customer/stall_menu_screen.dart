import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/seller_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class StallMenuScreen extends StatefulWidget {
  const StallMenuScreen({super.key});

  @override
  State<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends State<StallMenuScreen> {
  final _db = DatabaseService();
  String _selectedCategory = 'All';
  bool _isFavorited = false;
  SellerModel? _seller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seller == null) {
      _seller = ModalRoute.of(context)!.settings.arguments as SellerModel;
      _loadFavorite();
    }
  }

  Future<void> _loadFavorite() async {
    final customerId = context.read<AuthProvider>().currentUserId;
    if (customerId.isEmpty) return;
    final result = await _db.isFavoriteStall(customerId, _seller!.uid);
    if (mounted) setState(() => _isFavorited = result);
  }

  Future<void> _toggleFavorite() async {
    final customerId = context.read<AuthProvider>().currentUserId;
    if (customerId.isEmpty) return;
    final next = !_isFavorited;
    setState(() => _isFavorited = next);
    await _db.setFavoriteStall(customerId, _seller!.uid, next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(next ? 'Added to favourites' : 'Removed from favourites'),
        duration: const Duration(seconds: 2),
        backgroundColor: next ? AppColors.success : AppColors.textSecondary,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller =
        ModalRoute.of(context)!.settings.arguments as SellerModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 16),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red[300] : Colors.white,
                    size: 18,
                  ),
                  onPressed: _toggleFavorite,
                  constraints: const BoxConstraints(
                      minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  seller.imageUrl != null && seller.imageUrl!.isNotEmpty
                      ? Image.network(seller.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _heroBg())
                      : _heroBg(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  // Bottom info overlay
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Open badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: seller.isEffectivelyOpen
                                ? AppColors.success
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                seller.isEffectivelyOpen
                                    ? 'Open until ${seller.openUntil}'
                                    : 'Closed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          seller.stallName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stall info card
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.description.isNotEmpty
                        ? seller.description
                        : 'Authentic ${seller.cuisineType} cuisine.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.popular.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.popular, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              seller.rating > 0
                                  ? seller.rating.toStringAsFixed(1)
                                  : 'New',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Location
                      if (seller.location != null &&
                          seller.location!.isNotEmpty) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          seller.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!seller.isEffectivelyOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.warning, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This stall is currently closed. You can still browse the menu.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Menu header + category tabs
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.menuCategories.length,
                      itemBuilder: (_, i) {
                        final cat = AppConstants.menuCategories[i];
                        final selected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
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
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
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
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 4)),

          // Menu items
          StreamBuilder<List<MenuItemModel>>(
            stream: _db.menuItemsStream(seller.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                );
              }
              var items = snap.data ?? [];
              if (_selectedCategory != 'All') {
                items = items
                    .where((i) => i.category == _selectedCategory)
                    .toList();
              }
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fastfood_outlined,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          _selectedCategory == 'All'
                              ? 'No menu items yet'
                              : 'No items in "$_selectedCategory"',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _MenuItemTile(
                    item: items[i],
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/customer/item',
                      arguments: items[i].copyWith(
                        stallName: seller.stallName,
                      ),
                    ),
                  ),
                  childCount: items.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _heroBg() => Container(
        color: AppColors.primary,
        child: const Center(
          child: Icon(Icons.storefront, size: 80, color: Colors.white24),
        ),
      );
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const _MenuItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.all(12),
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder())
                    : _imgPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isPopular)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.popular,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(
                        '${item.prepTime} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
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

  Widget _imgPlaceholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.fastfood_outlined,
              color: AppColors.primary, size: 28),
        ),
      );
}
