import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/seller_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_helper.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final db = DatabaseService();
  late Future<SellerModel?> _sellerFuture;
  late OrderModel _initialOrder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialOrder =
        ModalRoute.of(context)!.settings.arguments as OrderModel;
    _sellerFuture = db.getSeller(_initialOrder.sellerId);
  }

  @override
  Widget build(BuildContext context) {
    final order = _initialOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Order #${order.id.replaceAll('-', '').substring(0, 6).toUpperCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<OrderModel?>(
        stream: db.orderStream(order.id),
        builder: (context, snap) {
          final current = snap.data ?? order;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stall info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordering from',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      current.stallName.isNotEmpty
                          ? Text(
                              current.stallName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : FutureBuilder<SellerModel?>(
                              future: db.getSeller(current.sellerId),
                              builder: (context, sellerSnap) {
                                final name = sellerSnap.data?.stallName ?? '';
                                return Text(
                                  name.isNotEmpty ? name : 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status steps card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StatusStep(
                        icon: Icons.receipt_long_outlined,
                        title: 'Order Placed',
                        subtitle: 'Waiting for confirmation',
                        state: _stepState(
                            current.status, AppConstants.statusPending),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusPending)),
                      _StatusStep(
                        icon: Icons.check_circle_outline,
                        title: 'Confirmed',
                        subtitle: 'Stall accepted your order',
                        state: _stepState(
                            current.status, AppConstants.statusConfirmed),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusConfirmed)),
                      _StatusStep(
                        icon: Icons.restaurant_outlined,
                        title: 'Preparing',
                        subtitle: 'Your food is being prepared',
                        state: _stepState(
                            current.status, AppConstants.statusPreparing),
                      ),
                      _StepConnector(
                          done: _isStepDone(
                              current.status, AppConstants.statusPreparing)),
                      _StatusStep(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Ready',
                        subtitle: 'Ready for pickup!',
                        state: _stepState(
                            current.status, AppConstants.statusReady),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Estimated time banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.popular.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time,
                            color: AppColors.popular, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${_estimatedTime(current.items)} minutes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order items card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...current.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                'RM ${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'RM ${current.totalAmount.toStringAsFixed(2)}',
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
                ),
                const SizedBox(height: 16),

                // Payment QR card — shown for all active orders
                if (current.status != AppConstants.statusCompleted &&
                    current.status != AppConstants.statusCancelled)
                  FutureBuilder<SellerModel?>(
                    future: _sellerFuture,
                    builder: (context, snap) {
                      final qrUrl = snap.data?.paymentQrUrl;
                      if (qrUrl == null || qrUrl.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _PaymentQrCard(
                        qrUrl: qrUrl,
                        total: current.totalAmount,
                        stallName: current.stallName,
                      );
                    },
                  ),

                // Rating card — only when completed and not yet rated
                if (current.status == AppConstants.statusCompleted &&
                    current.rating == null)
                  _RatingCard(order: current, db: db),

                if (current.status == AppConstants.statusCompleted &&
                    current.rating != null)
                  _RatedCard(rating: current.rating!, comment: current.comment),

                const SizedBox(height: 16),

                // Cancel button — only when still pending
                if (current.status == AppConstants.statusPending)
                  _CancelOrderButton(order: current, db: db),

                // Back to home button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/customer/home',
                      (route) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  _StepState _stepState(String currentStatus, String stepStatus) {
    final order = [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusReady,
      AppConstants.statusCompleted,
    ];
    final currentIdx = order.indexOf(currentStatus);
    final stepIdx = order.indexOf(stepStatus);
    if (currentIdx > stepIdx) return _StepState.done;
    if (currentIdx == stepIdx) return _StepState.active;
    return _StepState.pending;
  }

  bool _isStepDone(String currentStatus, String stepStatus) {
    return _stepState(currentStatus, stepStatus) == _StepState.done;
  }

  int _estimatedTime(List<OrderItemSnapshot> items) {
    if (items.isEmpty) return 10;
    final totalQty = items.fold(0, (sum, i) => sum + i.quantity);
    return (10 + totalQty * 2).clamp(10, 45);
  }
}

enum _StepState { done, active, pending }

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Widget indicator;

    switch (state) {
      case _StepState.done:
        color = AppColors.success;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
        break;
      case _StepState.active:
        color = AppColors.primary;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        );
        break;
      case _StepState.pending:
        color = AppColors.textHint;
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.textHint, size: 16),
        );
        break;
    }

    return Row(
      children: [
        indicator,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: state == _StepState.active
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: state == _StepState.pending
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (state == _StepState.done)
          const Icon(Icons.check, color: AppColors.success, size: 18),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool done;
  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        width: 2,
        height: 28,
        color: done ? AppColors.success : AppColors.border,
      ),
    );
  }
}

// ─── Payment QR Card ──────────────────────────────────────────────────────────

class _PaymentQrCard extends StatelessWidget {
  final String qrUrl;
  final double total;
  final String stallName;

  const _PaymentQrCard({
    required this.qrUrl,
    required this.total,
    required this.stallName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_2,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Scan QR to pay · DuitNow / TnG / Online Banking',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 200,
              height: 200,
              child: ImageHelper.buildImage(
                qrUrl,
                fit: BoxFit.contain,
                placeholder: const Center(
                  child: Icon(Icons.qr_code_2,
                      size: 60, color: AppColors.textHint),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Amount to pay: ',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
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
          ),
        ],
      ),
    );
  }
}

// ─── Rating Card (unrated completed order) ────────────────────────────────────

class _RatingCard extends StatefulWidget {
  final OrderModel order;
  final DatabaseService db;
  const _RatingCard({required this.order, required this.db});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  int _selected = 0;
  bool _submitting = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == 0) return;
    setState(() => _submitting = true);
    await widget.db.rateOrder(
      widget.order.id,
      widget.order.sellerId,
      _selected,
      comment: _commentController.text,
    );
    // Stream will update order.rating — card swaps automatically
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'How was your order?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.order.stallName,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selected = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    star <= _selected ? Icons.star : Icons.star_border,
                    size: 36,
                    color: star <= _selected
                        ? AppColors.popular
                        : AppColors.border,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Add a comment (optional)',
              hintStyle: const TextStyle(
                  fontSize: 13, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              counterStyle: const TextStyle(
                  fontSize: 11, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: (_selected == 0 || _submitting) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Submit Rating',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancel Order Button ──────────────────────────────────────────────────────

class _CancelOrderButton extends StatefulWidget {
  final OrderModel order;
  final DatabaseService db;
  const _CancelOrderButton({required this.order, required this.db});

  @override
  State<_CancelOrderButton> createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends State<_CancelOrderButton> {
  bool _cancelling = false;

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order?'),
        content: const Text(
            'Are you sure you want to cancel this order? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Order',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    await widget.db
        .updateOrderStatus(widget.order.id, AppConstants.statusCancelled);
    // Stream will update status — button disappears automatically
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: _cancelling ? null : _confirmCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _cancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.error),
                )
              : const Text('Cancel Order',
                  style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── Already Rated Card ───────────────────────────────────────────────────────

class _RatedCard extends StatelessWidget {
  final int rating;
  final String? comment;
  const _RatedCard({required this.rating, this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Thanks for your rating!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 28,
                  color: i < rating ? AppColors.popular : AppColors.border,
                ),
              );
            }),
          ),
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"$comment"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
