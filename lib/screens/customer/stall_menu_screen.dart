import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/seller_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/menu_item_card.dart';

class StallMenuScreen extends StatefulWidget {
  const StallMenuScreen({super.key});

  @override
  State<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends State<StallMenuScreen> {
  final _db = DatabaseService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final seller = ModalRoute.of(context)!.settings.arguments as SellerModel;
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with stall info
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                seller.stallName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: seller.imageUrl != null && seller.imageUrl!.isNotEmpty
                  ? Image.network(seller.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.storefront,
                        size: 72,
                        color: Colors.white30,
                      ),
                    ),
            ),
          ),

          // Stall details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          seller.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: seller.isOpen
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seller.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: seller.isOpen
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!seller.isOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.warning, size: 18),
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

          // Category filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.menuCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = AppConstants.menuCategories[i];
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Menu items list
          StreamBuilder<List<MenuItemModel>>(
            stream: _db.menuItemsStream(seller.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              var items = snapshot.data ?? [];
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
                        const Icon(Icons.fastfood,
                            size: 56, color: AppColors.textHint),
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
                  (_, i) {
                    final item = items[i];
                    final qty = cartProvider.items
                        .where((c) => c.menuItem.id == item.id)
                        .fold(0, (sum, c) => sum + c.quantity);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: MenuItemCard(
                        item: item,
                        cartQuantity: qty,
                        onAdd: () => _addToCart(
                            item, seller, cartProvider),
                        onDecrement: () =>
                            cartProvider.decrementItem(item.id),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              );
            },
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // Cart FAB
      floatingActionButton: cartProvider.isEmpty ||
              cartProvider.currentSellerId != seller.uid
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/customer/cart'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${cartProvider.itemCount} item${cartProvider.itemCount > 1 ? 's' : ''}'
                ' • RM ${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  void _addToCart(
      MenuItemModel item, SellerModel seller, CartProvider cartProvider) {
    final added = cartProvider.addItem(item, seller.uid, seller.stallName);
    if (!added) {
      // Cart has items from a different stall
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Start New Order?'),
          content: Text(
            'Your cart has items from "${cartProvider.currentStallName}". '
            'Starting a new order will clear your current cart.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                cartProvider.addItem(item, seller.uid, seller.stallName);
                Navigator.pop(context);
              },
              child: const Text('Clear & Add',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }
}
