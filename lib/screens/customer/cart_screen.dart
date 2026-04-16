import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onBrowse;
  const CartScreen({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 22),
              onPressed: () => _confirmClear(context, cart),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBrowse: onBrowse)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Ordering from card
                        Container(
                          margin: const EdgeInsets.all(16),
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
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.storefront_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ordering from',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    cart.currentStallName ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Cart items
                        ...cart.items.map((cartItem) {
                          return Container(
                            margin:
                                const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: cartItem.menuItem.imageUrl !=
                                            null
                                        ? Image.network(
                                            cartItem.menuItem.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _imgPlaceholder(),
                                          )
                                        : _imgPlaceholder(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.menuItem.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM ${cartItem.menuItem.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        _QtyBtn(
                                          icon: Icons.remove,
                                          onTap: () => context
                                              .read<CartProvider>()
                                              .decrementItem(
                                                  cartItem.menuItem.id),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          child: Text(
                                            '${cartItem.quantity}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        _QtyBtn(
                                          icon: Icons.add,
                                          filled: true,
                                          onTap: () => context
                                              .read<CartProvider>()
                                              .addItem(
                                                cartItem.menuItem,
                                                cart.currentSellerId!,
                                                cart.currentStallName!,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'RM ${cartItem.subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        // Estimated prep time banner
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.popular
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time,
                                    color: AppColors.popular, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated Preparation Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_estimatedPrepTime(cart)} minutes',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Bottom total + place order
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'RM ${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: cart.isPlacingOrder
                              ? null
                              : () => _placeOrder(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: cart.isPlacingOrder
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 20),
                          label: Text(
                            cart.isPlacingOrder
                                ? 'Placing Order...'
                                : 'Place Order',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  int _estimatedPrepTime(CartProvider cart) {
    if (cart.items.isEmpty) return 15;
    return cart.items
        .map((i) => i.menuItem.prepTime)
        .reduce((a, b) => a > b ? a : b);
  }

  Future<void> _placeOrder(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final order = await cart.placeOrder(
      customerId: auth.currentUserId,
      customerName: auth.customer?.name ?? 'Customer',
    );
    if (!context.mounted) return;
    if (order != null) {
      Navigator.pushNamed(
        context,
        '/customer/order-tracking',
        arguments: order,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?'),
        content:
            const Text('This will remove all items from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.fastfood_outlined,
              color: AppColors.primary, size: 22),
        ),
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyBtn(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback? onBrowse;
  const _EmptyCart({this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse restaurants and add items\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onBrowse ?? () => Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text('Browse Restaurants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              maximumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
