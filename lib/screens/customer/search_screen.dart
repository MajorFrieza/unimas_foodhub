import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../models/seller_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _db = DatabaseService();
  final _searchCtrl = TextEditingController();
  bool _searchRestaurants = true;
  String _selectedCuisine = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search input
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search food or restaurants...',
                    hintStyle: const TextStyle(
                        color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textHint, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tab toggle
                Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Restaurants',
                        selected: _searchRestaurants,
                        onTap: () =>
                            setState(() => _searchRestaurants = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabButton(
                        label: 'Food Items',
                        selected: !_searchRestaurants,
                        onTap: () =>
                            setState(() => _searchRestaurants = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Cuisine filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.cuisineTypes.map((c) {
                      final sel = c == _selectedCuisine;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCuisine = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: sel
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _searchRestaurants
                ? _RestaurantResults(
                    query: _query, cuisine: _selectedCuisine, db: _db)
                : _FoodItemResults(
                    query: _query, db: _db),
          ),
        ],
      ),
    );
  }
}

class _RestaurantResults extends StatelessWidget {
  final String query;
  final String cuisine;
  final DatabaseService db;

  const _RestaurantResults(
      {required this.query, required this.cuisine, required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SellerModel>>(
      stream: db.sellersStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        var sellers = snap.data ?? [];
        if (cuisine != 'All') {
          sellers =
              sellers.where((s) => s.cuisineType == cuisine).toList();
        }
        if (query.isNotEmpty) {
          sellers = sellers
              .where((s) => s.stallName.toLowerCase().contains(query))
              .toList();
        }
        if (sellers.isEmpty) {
          return _EmptyState(
              message: query.isEmpty
                  ? 'No restaurants found'
                  : 'No results for "$query"');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sellers.length,
          itemBuilder: (context, i) {
            final s = sellers[i];
            return _SellerTile(
              seller: s,
              onTap: () => Navigator.pushNamed(
                context,
                '/customer/menu',
                arguments: s,
              ),
            );
          },
        );
      },
    );
  }
}

class _FoodItemResults extends StatelessWidget {
  final String query;
  final DatabaseService db;

  const _FoodItemResults({required this.query, required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItemModel>>(
      stream: db.allMenuItemsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        var items = (snap.data ?? [])
            .where((i) => i.isAvailable)
            .toList();
        if (query.isNotEmpty) {
          items = items
              .where((i) => i.name.toLowerCase().contains(query))
              .toList();
        }
        if (items.isEmpty) {
          return _EmptyState(
              message: query.isEmpty
                  ? 'No food items found'
                  : 'No results for "$query"');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return _FoodItemTile(
              item: item,
              onTap: () => Navigator.pushNamed(
                context,
                '/customer/item',
                arguments: item,
              ),
            );
          },
        );
      },
    );
  }
}

class _SellerTile extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onTap;

  const _SellerTile({required this.seller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen = seller.isEffectivelyOpen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Square image with border
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: ImageHelper.buildImage(
                  seller.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: const Center(
                      child: Icon(Icons.storefront_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.stallName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 13, color: AppColors.popular),
                      const SizedBox(width: 3),
                      Text(
                        seller.rating > 0
                            ? seller.rating.toStringAsFixed(1)
                            : 'New',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      const Text('•',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        seller.cuisineType,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Open/Closed badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOpen
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isOpen ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const _FoodItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Square image with border
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: ImageHelper.buildImage(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: const Center(
                      child: Icon(Icons.fastfood_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'RM ${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_outlined,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
