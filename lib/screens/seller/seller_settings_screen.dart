import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final seller = auth.seller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showEditSheet(context, auth),
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.primary, size: 18),
            label: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  // Avatar — stall image or initial letter
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.hardEdge,
                    child: seller?.imageUrl != null &&
                            seller!.imageUrl!.isNotEmpty
                        ? Image.network(seller.imageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _stallInitialAvatar(seller.stallName))
                        : _stallInitialAvatar(seller?.stallName ?? ''),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    seller?.stallName ?? 'My Stall',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seller?.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Seller',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (seller?.rating != null && seller!.rating > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.popular.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: AppColors.popular),
                              const SizedBox(width: 4),
                              Text(
                                seller.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.popular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stall info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.store_outlined,
                    label: 'Stall Name',
                    value: seller?.stallName ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: (seller?.description ?? '').isNotEmpty
                        ? seller!.description
                        : '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: (seller?.location ?? '').isNotEmpty
                        ? seller!.location!
                        : '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.restaurant_outlined,
                    label: 'Cuisine Type',
                    value: seller?.cuisineType ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: (seller?.phone ?? '').isNotEmpty
                        ? seller!.phone
                        : '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Operating Hours',
                    value: '${seller?.openFrom ?? '08:00'} – ${seller?.openUntil ?? '17:00'}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Log out
            Container(
              color: Colors.white,
              child: ListTile(
                onTap: () => _confirmLogout(context, auth),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout,
                      size: 18, color: AppColors.error),
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _stallInitialAvatar(String stallName) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: Text(
            stallName.isNotEmpty ? stallName[0].toUpperCase() : 'S',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

  void _showEditSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditStallSheet(auth: auth),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (route) => false);
              }
            },
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Bottom Sheet ────────────────────────────────────────────────────────

class _EditStallSheet extends StatefulWidget {
  final AuthProvider auth;
  const _EditStallSheet({required this.auth});

  @override
  State<_EditStallSheet> createState() => _EditStallSheetState();
}

class _EditStallSheetState extends State<_EditStallSheet> {
  late final TextEditingController _stallNameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _imageUrlCtrl;
  late String _selectedCuisine;
  late TimeOfDay _openFrom;
  late TimeOfDay _openUntil;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.auth.seller;
    _stallNameCtrl = TextEditingController(text: s?.stallName ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _locationCtrl = TextEditingController(text: s?.location ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _imageUrlCtrl = TextEditingController(text: s?.imageUrl ?? '');
    _selectedCuisine = s?.cuisineType ?? 'Malay';
    _openFrom = _parseTime(s?.openFrom ?? '08:00');
    _openUntil = _parseTime(s?.openUntil ?? '17:00');
    // Ensure selected cuisine is valid
    final validTypes =
        AppConstants.cuisineTypes.where((c) => c != 'All').toList();
    if (!validTypes.contains(_selectedCuisine)) {
      _selectedCuisine = validTypes.first;
    }
  }

  @override
  void dispose() {
    _stallNameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final stallName = _stallNameCtrl.text.trim();
    if (stallName.isEmpty) return;

    setState(() => _saving = true);
    try {
      final db = DatabaseService();
      final imageUrl = _imageUrlCtrl.text.trim().isEmpty
          ? null
          : _imageUrlCtrl.text.trim();
      final openFrom = _formatTime(_openFrom);
      final openUntil = _formatTime(_openUntil);
      await db.updateSellerProfile(widget.auth.currentUserId, {
        'stallName': stallName,
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'cuisineType': _selectedCuisine,
        'imageUrl': imageUrl,
        'openFrom': openFrom,
        'openUntil': openUntil,
      });
      widget.auth.updateSellerLocally(
        stallName: stallName,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        cuisineType: _selectedCuisine,
        imageUrl: imageUrl,
        openFrom: openFrom,
        openUntil: openUntil,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final cuisines =
        AppConstants.cuisineTypes.where((c) => c != 'All').toList();

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Stall Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Stall banner image preview
            GestureDetector(
              onTap: _showImageUrlDialog,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _imageUrlCtrl,
                builder: (context, value, _) {
                  final hasUrl = value.text.trim().isNotEmpty;
                  return Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1.5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: hasUrl
                        ? Stack(fit: StackFit.expand, children: [
                            Image.network(value.text.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder()),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _imageUrlCtrl.clear()),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Tap to change',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ),
                            ),
                          ])
                        : _imagePlaceholder(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Stall Name'),
            _textField(
              controller: _stallNameCtrl,
              hint: 'e.g. Mak Cik Nasi Lemak',
              icon: Icons.store_outlined,
            ),
            const SizedBox(height: 14),

            _fieldLabel('Description'),
            _textField(
              controller: _descCtrl,
              hint: 'Brief description of your stall',
              icon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            _fieldLabel('Location'),
            _textField(
              controller: _locationCtrl,
              hint: 'e.g. Cafe Utama, Level 1',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),

            _fieldLabel('Phone Number'),
            _textField(
              controller: _phoneCtrl,
              hint: 'e.g. 011-12345678',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _fieldLabel('Operating Hours'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isFrom: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Opens',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint)),
                              Text(
                                _formatTime(_openFrom),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('–',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.textSecondary)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isFrom: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Closes',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint)),
                              Text(
                                _formatTime(_openUntil),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _fieldLabel('Cuisine Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cuisines.map((c) {
                final selected = c == _selectedCuisine;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCuisine = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
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
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    try {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isFrom}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _openFrom : _openUntil,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _openFrom = picked;
        } else {
          _openUntil = picked;
        }
      });
    }
  }

  void _showImageUrlDialog() {
    final tempCtrl = TextEditingController(text: _imageUrlCtrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Stall Banner Image'),
        content: TextField(
          controller: tempCtrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://example.com/stall.jpg',
            hintStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _imageUrlCtrl.text = tempCtrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Apply',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          const Text('Add Banner Photo',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          const Text('Tap to add image URL',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
