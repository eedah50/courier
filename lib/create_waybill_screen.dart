import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_screen.dart';
import 'theme.dart';

class _Category {
  final String value; // stored value (unchanged from before)
  final String label;
  final IconData icon;
  const _Category(this.value, this.label, this.icon);
}

class _Tier {
  final String value; // stored value (unchanged from before)
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badge;
  const _Tier(this.value, this.title, this.subtitle, this.icon, [this.badge]);
}

const _categories = [
  _Category('Documents & Legal', 'Documents', Icons.description_outlined),
  _Category('Electronics & Gadgets', 'Electronics', Icons.devices_other_rounded),
  _Category('Fragile & Gifts', 'Fragile & Gifts', Icons.card_giftcard_rounded),
  _Category('Food & Perishables', 'Food', Icons.restaurant_rounded),
  _Category('Heavy Cargo', 'Heavy Cargo', Icons.inventory_2_outlined),
];

const _tiers = [
  _Tier('Express (30-60 mins)', 'Express', 'Direct dispatch · 30-60 mins',
      Icons.bolt_rounded, 'FASTEST'),
  _Tier('Standard (2-4 hours)', 'Standard', 'Consolidated · 2-4 hours',
      Icons.schedule_rounded),
  _Tier('Scheduled Delivery', 'Scheduled', 'Pick a future delivery time',
      Icons.event_rounded),
];

class CreateWaybillScreen extends StatefulWidget {
  const CreateWaybillScreen({super.key});

  @override
  State<CreateWaybillScreen> createState() => _CreateWaybillScreenState();
}

class _CreateWaybillScreenState extends State<CreateWaybillScreen> {
  final _formKey = GlobalKey<FormState>();

  // Sender Controllers
  final _senderNameController = TextEditingController(text: 'Amara Okafor');
  final _senderPhoneController = TextEditingController(text: '+234 802 111 2233');
  final _pickupAddressController = TextEditingController(text: '12 Ikeja City Mall, Lagos');

  // Recipient Controllers
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _dropoffAddressController = TextEditingController();

  // Package Details
  String _category = 'Documents & Legal';
  final _weightController = TextEditingController(text: '1.5');
  final _itemDescController = TextEditingController();
  String _serviceTier = 'Express (30-60 mins)';

  bool _isFragile = false;
  bool _requiresInsurance = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Rebuild live (progress bar, route preview, fee) as the user types.
    for (final c in [
      _senderNameController,
      _senderPhoneController,
      _pickupAddressController,
      _recipientNameController,
      _recipientPhoneController,
      _dropoffAddressController,
      _weightController,
      _itemDescController,
    ]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _pickupAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _dropoffAddressController.dispose();
    _weightController.dispose();
    _itemDescController.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Fee logic (unchanged) + a matching breakdown for display
  // ---------------------------------------------------------------------------
  double get _estimatedFee {
    double w = double.tryParse(_weightController.text) ?? 1.0;
    double base = 2500.0;
    if (_serviceTier.contains('Express')) base *= 1.4;
    if (_requiresInsurance) base += 500.0;
    return base + (w * 400.0);
  }

  List<MapEntry<String, double>> get _feeLines {
    final w = double.tryParse(_weightController.text) ?? 1.0;
    final lines = <MapEntry<String, double>>[
      MapEntry('Base delivery fee', 2500.0),
    ];
    if (_serviceTier.contains('Express')) {
      lines.add(MapEntry('Express dispatch (+40%)', 1000.0));
    }
    if (_requiresInsurance) {
      lines.add(MapEntry('Waybill insurance', 500.0));
    }
    lines.add(MapEntry('Weight (${_num(w)} kg × ₦400)', w * 400.0));
    return lines;
  }

  String _num(double v) =>
      v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  String _naira(double v) =>
      '₦${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  void _bumpWeight(double delta) {
    final w = double.tryParse(_weightController.text) ?? 1.0;
    final next = (w + delta).clamp(0.5, 100.0);
    _weightController.text = _num(next);
  }

  int get _filledRequired {
    return [
      _senderNameController,
      _senderPhoneController,
      _pickupAddressController,
      _recipientNameController,
      _recipientPhoneController,
      _dropoffAddressController,
      _itemDescController,
      _weightController,
    ].where((c) => c.text.trim().isNotEmpty).length;
  }

  Future<void> _submitWaybill() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _toast('Please fill in all required recipient & pickup fields.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _loading = false);

    final waybillId = 'SKR-WAY-${8800 + DateTime.now().second}';
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        var copied = false;
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: StatefulBuilder(
              builder: (context, setLocal) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lemon,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lemon.withValues(alpha: 0.6),
                            blurRadius: 26,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.black,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Waybill Created!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A nearby courier has been notified to pick up your package.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Waybill ID chip with copy
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WAYBILL ID',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              waybillId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          tooltip: 'Copy ID',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: waybillId));
                            setLocal(() => copied = true);
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              copied ? Icons.check_rounded : Icons.copy_rounded,
                              key: ValueKey(copied),
                              size: 20,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.lemon,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx); // pop dialog
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              amount: _estimatedFee,
                              waybillId: waybillId,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PROCEED TO PAYMENT & TRACKING',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shared field styling
  // ---------------------------------------------------------------------------
  InputDecoration _inputDeco(
      String label,
      IconData icon, {
        String? hint,
        Widget? prefix,
        Widget? suffix,
      }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13.5),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13.5),
      floatingLabelStyle: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w800,
      ),
      prefixIcon: prefix ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.lemon.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: AppColors.black),
            ),
          ),
      prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      enabledBorder: border(Colors.black.withValues(alpha: 0.10)),
      focusedBorder: border(AppColors.black, 1.6),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  // ---------------------------------------------------------------------------
  // Header: black hero with progress
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    final progress = _filledRequired / 8;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lemon.withValues(alpha: 0.36),
                    AppColors.lemon.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.lemon.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.lemon.withValues(alpha: 0.55),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: AppColors.lemon, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'VERIFIED COURIERS',
                              style: TextStyle(
                                color: AppColors.lemon,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.lemon, AppColors.yellow],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lemon.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Waybill',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Instant doorstep dispatch, in 4 quick steps.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Completion progress
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 5,
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.lemon,
                                            AppColors.yellow,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$_filledRequired of 8 details',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Live route preview (pickup -> dropoff)
  // ---------------------------------------------------------------------------
  Widget _buildRouteCard() {
    final pickup = _pickupAddressController.text.trim();
    final drop = _dropoffAddressController.text.trim();

    Widget stop(String label, String value, String placeholder) {
      final empty = value.isEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            empty ? placeholder : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: empty ? Colors.black26 : AppColors.black,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lemon,
                    border: Border.all(color: AppColors.black, width: 3),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  stop('PICKUP', pickup, 'Add pickup address'),
                  const SizedBox(height: 16),
                  stop('DROPOFF', drop, 'Add recipient address'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Fee breakdown
  // ---------------------------------------------------------------------------
  Widget _buildBreakdown() {
    final lines = _feeLines;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.lemon, size: 18),
              SizedBox(width: 8),
              Text(
                'FEE BREAKDOWN',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l.key,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _naira(l.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12, top: 2),
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _naira(_estimatedFee),
                style: const TextStyle(
                  color: AppColors.lemon,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sticky bottom bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ESTIMATED FEE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _naira(_estimatedFee),
                    key: ValueKey(_estimatedFee.round()),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.lemon,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loading ? null : _submitWaybill,
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.lemon,
                    ),
                  )
                      : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CREATE WAYBILL',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          fontSize: 13.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _buildRouteCard(),
                    const SizedBox(height: 18),

                    // 1. Sender
                    _SectionCard(
                      step: 1,
                      title: 'Sender (Pickup)',
                      subtitle: 'Where should the courier collect the package?',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _senderNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: _inputDeco(
                                'Sender full name', Icons.person_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Sender name required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _senderPhoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                            ],
                            decoration: _inputDeco(
                                'Sender phone number', Icons.phone_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Phone number required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pickupAddressController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.fullStreetAddress],
                            decoration: _inputDeco(
                                'Pickup street address', Icons.location_on_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Pickup address required'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // 2. Recipient
                    _SectionCard(
                      step: 2,
                      title: 'Recipient (Dropoff)',
                      subtitle: 'Who is receiving it, and where?',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _recipientNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              'Recipient full name',
                              Icons.person_outline_rounded,
                              hint: 'e.g. David Mensah',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Recipient name required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recipientPhoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                            ],
                            decoration: _inputDeco(
                              'Recipient phone number',
                              Icons.phone_iphone_rounded,
                              hint: '+234 801 234 5678',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Recipient phone required';
                              }
                              if (v.trim().length < 7) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dropoffAddressController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              'Dropoff destination address',
                              Icons.pin_drop_rounded,
                              hint: '18 Maryland Estate, Lagos',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Dropoff address required'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // 3. Package
                    _SectionCard(
                      step: 3,
                      title: 'Package Details',
                      subtitle: 'Tell us what you are sending.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _MiniLabel('CATEGORY'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in _categories)
                                _CategoryChip(
                                  category: c,
                                  selected: _category == c.value,
                                  onTap: () => setState(() {
                                    _category = c.value;
                                    if (c.value == 'Fragile & Gifts') {
                                      _isFragile = true;
                                    }
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _itemDescController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              'Item description',
                              Icons.inventory_2_outlined,
                              hint: 'e.g. iPhone 15 Pro',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Description required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _weightController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                            decoration: _inputDeco(
                              'Weight (kg)',
                              Icons.fitness_center_rounded,
                              prefix: IconButton(
                                tooltip: 'Less',
                                icon: const Icon(Icons.remove_circle_rounded),
                                color: AppColors.black,
                                onPressed: () => _bumpWeight(-0.5),
                              ),
                              suffix: IconButton(
                                tooltip: 'More',
                                icon: const Icon(Icons.add_circle_rounded),
                                color: AppColors.black,
                                onPressed: () => _bumpWeight(0.5),
                              ),
                            ),
                            validator: (v) {
                              final w = double.tryParse(v?.trim() ?? '');
                              if (v == null || v.trim().isEmpty) {
                                return 'Weight required';
                              }
                              if (w == null || w <= 0) {
                                return 'Enter a valid weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _OptionTile(
                            icon: Icons.wine_bar_rounded,
                            title: 'Fragile item',
                            subtitle: 'Courier handles it with extra care',
                            value: _isFragile,
                            onChanged: (v) => setState(() => _isFragile = v),
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            icon: Icons.shield_outlined,
                            title: 'Waybill insurance',
                            subtitle: 'Covers loss or damage · +₦500',
                            value: _requiresInsurance,
                            onChanged: (v) =>
                                setState(() => _requiresInsurance = v),
                          ),
                        ],
                      ),
                    ),

                    // 4. Tier
                    _SectionCard(
                      step: 4,
                      title: 'Delivery Speed',
                      subtitle: 'Choose how fast it should arrive.',
                      child: Column(
                        children: [
                          for (var i = 0; i < _tiers.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _TierCard(
                              tier: _tiers[i],
                              selected: _serviceTier == _tiers[i].value,
                              onTap: () => setState(
                                      () => _serviceTier = _tiers[i].value),
                            ),
                          ],
                        ],
                      ),
                    ),

                    _buildBreakdown(),
                  ],
                ),
              ),
            ),
            if (!keyboardOpen) _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Section card with numbered badge
// -----------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    color: AppColors.lemon,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
        color: Colors.black45,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Category chip (replaces the dropdown)
// -----------------------------------------------------------------------------
class _CategoryChip extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.black : const Color(0xFFF6F5EF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? AppColors.black
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 17,
              color: selected ? AppColors.lemon : Colors.black54,
            ),
            const SizedBox(width: 7),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.lemon : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Switch tile (replaces the checkboxes)
// -----------------------------------------------------------------------------
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: value
              ? AppColors.lemon.withValues(alpha: 0.18)
              : const Color(0xFFF6F5EF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value
                ? AppColors.lemon
                : Colors.black.withValues(alpha: 0.06),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: value ? AppColors.lemon : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.lemon,
              activeTrackColor: AppColors.black,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black12,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Delivery tier card (replaces the dropdown)
// -----------------------------------------------------------------------------
class _TierCard extends StatelessWidget {
  final _Tier tier;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lemon.withValues(alpha: 0.18)
              : const Color(0xFFF6F5EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.black
                : Colors.black.withValues(alpha: 0.06),
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? AppColors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tier.icon,
                color: selected ? AppColors.lemon : AppColors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                      if (tier.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tier.badge!,
                            style: const TextStyle(
                              color: AppColors.lemon,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.black : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.black : Colors.black26,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                  color: AppColors.lemon, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}