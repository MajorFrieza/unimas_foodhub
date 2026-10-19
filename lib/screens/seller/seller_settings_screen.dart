import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/seller_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_helper.dart';

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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.hardEdge,
                    child: ImageHelper.buildImage(
                      seller?.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: _stallInitialAvatar(seller?.stallName ?? ''),
                    ),
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
                    icon: Icons.pin_drop_outlined,
                    label: 'GPS Coordinates',
                    value: (seller?.latitude != null &&
                            seller?.longitude != null)
                        ? '${seller!.latitude!.toStringAsFixed(6)}, ${seller.longitude!.toStringAsFixed(6)}'
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
                  _ScheduleInfoRow(
                      operatingHours: seller?.operatingHours),
                  const Divider(height: 1),
                  _QrInfoRow(qrUrl: seller?.paymentQrUrl),
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

// ─── Day schedule data class ──────────────────────────────────────────────────

class _DaySchedule {
  bool isOpen;
  TimeOfDay openFrom;
  TimeOfDay openUntil;

  _DaySchedule({
    required this.isOpen,
    required this.openFrom,
    required this.openUntil,
  });
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
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _phoneCtrl;
  String? _imageData;
  String? _paymentQrData;
  late String _selectedCuisine;
  late Map<String, _DaySchedule> _schedule;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.auth.seller;
    _stallNameCtrl = TextEditingController(text: s?.stallName ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _locationCtrl = TextEditingController(text: s?.location ?? '');
    _latCtrl = TextEditingController(
        text: s?.latitude != null ? '${s!.latitude}' : '');
    _lngCtrl = TextEditingController(
        text: s?.longitude != null ? '${s!.longitude}' : '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _imageData = s?.imageUrl;
    _paymentQrData = s?.paymentQrUrl;
    _selectedCuisine = s?.cuisineType ?? 'Malay';

    // Ensure selected cuisine is valid
    final validTypes =
        AppConstants.cuisineTypes.where((c) => c != 'All').toList();
    if (!validTypes.contains(_selectedCuisine)) {
      _selectedCuisine = validTypes.first;
    }

    // Build per-day schedule from existing data or defaults (Mon–Fri open, Sat–Sun closed)
    _schedule = {};
    for (var i = 0; i < SellerModel.dayKeys.length; i++) {
      final key = SellerModel.dayKeys[i];
      final dayData = s?.operatingHours?[key];
      final defaultOpen = i < 5;
      _schedule[key] = _DaySchedule(
        isOpen: dayData != null
            ? (dayData['isOpen'] as bool? ?? false)
            : defaultOpen,
        openFrom: _parseTime(dayData?['openFrom'] ?? '08:00'),
        openUntil: _parseTime(dayData?['openUntil'] ?? '17:00'),
      );
    }
  }

  @override
  void dispose() {
    _stallNameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final stallName = _stallNameCtrl.text.trim();
    if (stallName.isEmpty) return;

    setState(() => _saving = true);
    try {
      final db = DatabaseService();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());

      final operatingHours = <String, Map<String, dynamic>>{};
      for (final key in _schedule.keys) {
        final day = _schedule[key]!;
        operatingHours[key] = {
          'isOpen': day.isOpen,
          'openFrom': _fmt(day.openFrom),
          'openUntil': _fmt(day.openUntil),
        };
      }

      await db.updateSellerProfile(widget.auth.currentUserId, {
        'stallName': stallName,
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'latitude': lat,
        'longitude': lng,
        'phone': _phoneCtrl.text.trim(),
        'cuisineType': _selectedCuisine,
        'imageUrl': _imageData,
        'paymentQrUrl': _paymentQrData,
        'operatingHours': operatingHours,
      });
      widget.auth.updateSellerLocally(
        stallName: stallName,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        latitude: lat,
        longitude: lng,
        phone: _phoneCtrl.text.trim(),
        cuisineType: _selectedCuisine,
        imageUrl: _imageData,
        paymentQrUrl: _paymentQrData,
        operatingHours: operatingHours,
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

  TimeOfDay _parseTime(String t) {
    try {
      final parts = t.split(':');
      return TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _displayTime(TimeOfDay t) {
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickDayTime(String dayKey, {required bool isFrom}) async {
    final day = _schedule[dayKey]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? day.openFrom : day.openUntil,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          day.openFrom = picked;
        } else {
          day.openUntil = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final data = await ImageHelper.pickFromGallery();
    if (data != null) setState(() => _imageData = data);
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

            // Banner image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5),
                ),
                clipBehavior: Clip.hardEdge,
                child: _imageData != null
                    ? Stack(fit: StackFit.expand, children: [
                        ImageHelper.buildImage(_imageData,
                            placeholder: _imagePlaceholder()),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageData = null),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
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
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Tap to change',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ])
                    : _imagePlaceholder(),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Stall Name'),
            _textField(
                controller: _stallNameCtrl,
                hint: 'e.g. Mak Cik Nasi Lemak',
                icon: Icons.store_outlined),
            const SizedBox(height: 14),

            _fieldLabel('Description'),
            _textField(
                controller: _descCtrl,
                hint: 'Brief description of your stall',
                icon: Icons.description_outlined,
                maxLines: 2),
            const SizedBox(height: 14),

            _fieldLabel('Location'),
            _textField(
                controller: _locationCtrl,
                hint: 'e.g. Cafe Utama, Level 1',
                icon: Icons.location_on_outlined),
            const SizedBox(height: 14),

            _fieldLabel('GPS Coordinates (for map pin)'),
            if (_latCtrl.text.isNotEmpty && _lngCtrl.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_latCtrl.text}, ${_lngCtrl.text}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _latCtrl.clear();
                        _lngCtrl.clear();
                      }),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    controller: _latCtrl,
                    hint: 'Latitude',
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    controller: _lngCtrl,
                    hint: 'Longitude',
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _fieldLabel('Phone Number'),
            _textField(
                controller: _phoneCtrl,
                hint: 'e.g. 011-12345678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),

            // ── Payment QR ──────────────────────────────────────────────────
            _fieldLabel('Payment QR Code (DuitNow / TnG / Others)'),
            GestureDetector(
              onTap: () async {
                final data = await ImageHelper.pickFromGallery();
                if (data != null) setState(() => _paymentQrData = data);
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5),
                ),
                clipBehavior: Clip.hardEdge,
                child: _paymentQrData != null
                    ? Stack(fit: StackFit.expand, children: [
                        ImageHelper.buildImage(_paymentQrData,
                            fit: BoxFit.contain,
                            placeholder: _qrPlaceholder()),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _paymentQrData = null),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
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
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Tap to change',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ])
                    : _qrPlaceholder(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Operating hours ──────────────────────────────────────────────
            _fieldLabel('Operating Hours'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(SellerModel.dayKeys.length, (i) {
                  final key = SellerModel.dayKeys[i];
                  final label = SellerModel.dayShort[i];
                  final day = _schedule[key]!;
                  final isLast = i == SellerModel.dayKeys.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: day.isOpen,
                              onChanged: (v) =>
                                  setState(() => day.isOpen = v),
                              activeThumbColor: AppColors.success,
                              activeTrackColor:
                                  AppColors.success.withValues(alpha: 0.3),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            if (day.isOpen) ...[
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDayTime(key, isFrom: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _displayTime(day.openFrom),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('–',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _pickDayTime(key, isFrom: false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _displayTime(day.openUntil),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              const Expanded(
                                child: Text(
                                  'Closed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                            height: 1, indent: 14, endIndent: 14),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Cuisine type ─────────────────────────────────────────────────
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
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _qrPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_2,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          const Text('Upload Payment QR',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          const Text('Screenshot your DuitNow / TnG QR',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );

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
          const Text('Tap to pick from gallery',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

// ─── QR Info Row (read-only) ─────────────────────────────────────────────────

class _QrInfoRow extends StatelessWidget {
  final String? qrUrl;
  const _QrInfoRow({this.qrUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.qr_code_2, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment QR',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textHint)),
                const SizedBox(height: 6),
                if (qrUrl == null)
                  const Text('Not set',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textPrimary))
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ImageHelper.buildImage(qrUrl,
                          fit: BoxFit.contain,
                          placeholder: const Icon(Icons.qr_code_2,
                              color: AppColors.primary, size: 40)),
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

// ─── Schedule Info Row (read-only) ────────────────────────────────────────────

class _ScheduleInfoRow extends StatelessWidget {
  final Map<String, Map<String, dynamic>>? operatingHours;
  const _ScheduleInfoRow({this.operatingHours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time_outlined,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Operating Hours',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textHint)),
                const SizedBox(height: 6),
                if (operatingHours == null)
                  const Text('Not set',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textPrimary))
                else
                  ...List.generate(SellerModel.dayKeys.length, (i) {
                    final key = SellerModel.dayKeys[i];
                    final label = SellerModel.dayLabels[i];
                    final day = operatingHours![key];
                    final isOpen = day?['isOpen'] as bool? ?? false;
                    final from = isOpen
                        ? SellerModel.formatDisplayTime(
                            day?['openFrom'] ?? '08:00')
                        : null;
                    final until = isOpen
                        ? SellerModel.formatDisplayTime(
                            day?['openUntil'] ?? '17:00')
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            isOpen ? '$from – $until' : 'Closed',
                            style: TextStyle(
                              fontSize: 13,
                              color: isOpen
                                  ? AppColors.textSecondary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
