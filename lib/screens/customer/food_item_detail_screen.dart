import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';

class FoodItemDetailScreen extends StatefulWidget {
  const FoodItemDetailScreen({super.key});

  @override
  State<FoodItemDetailScreen> createState() => _FoodItemDetailScreenState();
}

class _FoodItemDetailScreenState extends State<FoodItemDetailScreen> {
  int _quantity = 1;
  bool _isFavorited = false;
  bool _favLoaded = false;
  final _db = DatabaseService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_favLoaded) {
      _favLoaded = true;
      final item = ModalRoute.of(context)!.settings.arguments as MenuItemModel;
      final customerId = context.read<AuthProvider>().currentUserId;
      if (customerId.isNotEmpty) {
        _db.isFavoriteStall(customerId, item.sellerId).then((val) {
          if (mounted) setState(() => _isFavorited = val);
        });
      }
    }
  }

  Future<void> _toggleFavorite(String customerId, String sellerId) async {
    final next = !_isFavorited;
    setState(() => _isFavorited = next);
    await _db.setFavoriteStall(customerId, sellerId, next);
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
    final item =
        ModalRoute.of(context)!.settings.arguments as MenuItemModel;
    final cart = context.watch<CartProvider>();
    final customerId = context.read<AuthProvider>().currentUserId;
    final total = item.price * _quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: 260,
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
                  onPressed: () => _toggleFavorite(customerId, item.sellerId),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _heroBg())
                      : _heroBg(),
                  if (item.isPopular)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.popular,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Item details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : 'A delicious ${item.category.toLowerCase()} dish.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: '${item.prepTime} min',
                      ),
                      if (item.calories > 0)
                        _InfoChip(
                          icon: Icons.local_fire_department_outlined,
                          label: '${item.calories} cal',
                        ),
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: item.category,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Quantity selector
                  Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      // Minus
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Plus
                      _QtyButton(
                        icon: Icons.add,
                        filled: true,
                        onTap: () => setState(() => _quantity++),
                      ),
                      const SizedBox(width: 16),
                      // Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'RM ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Add to Cart button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: item.isAvailable
                          ? () => _addToCart(context, item, cart)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined,
                          size: 20),
                      label: Text(
                        item.isAvailable
                            ? 'Add to Cart'
                            : 'Currently Unavailable',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(
      BuildContext context, MenuItemModel item, CartProvider cart) {
    // Add item _quantity times
    bool added = false;
    for (int i = 0; i < _quantity; i++) {
      final result = cart.addItem(item, item.sellerId, item.stallName);
      if (!result && i == 0) {
        // Different stall — ask to clear
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Start New Order?'),
            content: Text(
              'Your cart has items from "${cart.currentStallName}". '
              'Starting a new order will clear your current cart.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  cart.clearCart();
                  for (int j = 0; j < _quantity; j++) {
                    cart.addItem(item, item.sellerId, item.stallName);
                  }
                  Navigator.pop(context);
                  _showAddedSnackbar(context);
                },
                child: const Text('Clear & Add',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
        return;
      }
      added = true;
    }
    if (added) _showAddedSnackbar(context);
  }

  void _showAddedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/customer/cart'),
        ),
      ),
    );
  }

  Widget _heroBg() => Container(
        color: AppColors.primary,
        child: const Center(
          child:
              Icon(Icons.fastfood, size: 80, color: Colors.white24),
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _QtyButton(
      {required this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(
                  color: onTap != null
                      ? AppColors.primary
                      : AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? Colors.white
              : onTap != null
                  ? AppColors.primary
                  : AppColors.textHint,
        ),
      ),
    );
  }
}
