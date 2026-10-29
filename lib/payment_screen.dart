import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'finding_courier_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String waybillId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.waybillId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0: Wallet, 1..n: saved cards, n+1: Bank Transfer
  double _walletBalance = 14500.00;
  bool _loading = false;

  final List<Map<String, dynamic>> _savedCards = [
    {'title': 'Visa ending in 4921', 'expiry': '08/26', 'icon': Icons.credit_card_rounded, 'isDefault': true},
    {'title': 'Mastercard ending in 8830', 'expiry': '12/25', 'icon': Icons.credit_card_rounded, 'isDefault': false},
  ];

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
    );
    return '₦$whole.${parts[1]}';
  }

  String _fmtWhole(double v) => _fmt(v).replaceFirst(RegExp(r'\.00$'), '');

  String _brandOf(String title) {
    final t = title.toLowerCase();
    if (t.contains('visa')) return 'VISA';
    if (t.contains('master')) return 'MC';
    return '';
  }

  int get _bankIndex => _savedCards.length + 1;

  String get _selectedLabel {
    if (_selectedMethod == 0) return 'Sekure Wallet';
    if (_selectedMethod == _bankIndex) return 'Instant Bank Transfer';
    return _savedCards[_selectedMethod - 1]['title'] as String;
  }

  bool get _walletShort => _walletBalance < widget.amount;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _deco(String label, IconData icon, {String? hint, String? prefixText}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13.5),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13.5),
      floatingLabelStyle: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w800,
      ),
      prefixIcon: Padding(
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
      filled: true,
      fillColor: const Color(0xFFF6F5EF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(Colors.black.withValues(alpha: 0.08)),
      focusedBorder: border(AppColors.black, 1.6),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  Widget _sheetHandle() => Center(
    child: Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  Widget _inlineError(ValueNotifier<String?> err) {
    return ValueListenableBuilder<String?>(
      valueListenable: err,
      builder: (context, msg, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: msg == null
              ? const SizedBox(width: double.infinity)
              : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Add card sheet (with live card preview)
  // ---------------------------------------------------------------------------
  void _showAddCardModal() {
    final numCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final err = ValueNotifier<String?>(null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 14, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const Text(
                'Add New Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Debit or credit card',
                style: TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
              const SizedBox(height: 18),

              // Live preview
              AnimatedBuilder(
                animation: Listenable.merge([numCtrl, expCtrl]),
                builder: (context, _) {
                  final digits = numCtrl.text.replaceAll(' ', '');
                  final padded = digits.padRight(16, '•');
                  final groups = [
                    for (var i = 0; i < 4; i++) padded.substring(i * 4, i * 4 + 4),
                  ].join('   ');
                  final brand = digits.startsWith('4')
                      ? 'VISA'
                      : (digits.startsWith('5') || digits.startsWith('2'))
                      ? 'MASTERCARD'
                      : 'CARD';
                  return Container(
                    height: 172,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1C1C1C), AppColors.black],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -50,
                          right: -30,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.lemon.withValues(alpha: 0.40),
                                  AppColors.lemon.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [AppColors.lemon, AppColors.yellow],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    brand,
                                    style: const TextStyle(
                                      color: AppColors.lemon,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                groups,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'EXPIRES',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    expCtrl.text.isEmpty ? 'MM/YY' : expCtrl.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),
              TextField(
                controller: numCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => err.value = null,
                inputFormatters: [_CardNumberFormatter()],
                decoration: _deco('Card number', Icons.payment_rounded,
                    hint: '4532 1234 5678 4921'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => err.value = null,
                      inputFormatters: [_ExpiryFormatter()],
                      decoration: _deco('Expiry date', Icons.calendar_month_rounded,
                          hint: 'MM/YY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      onChanged: (_) => err.value = null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration:
                      _deco('CVV', Icons.lock_rounded, hint: '123'),
                    ),
                  ),
                ],
              ),
              _inlineError(err),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
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
                  onPressed: () {
                    final digits = numCtrl.text.replaceAll(' ', '');
                    if (digits.length < 15) {
                      err.value = 'Please enter a valid card number.';
                      return;
                    }
                    final exp = expCtrl.text;
                    final month = exp.length == 5
                        ? int.tryParse(exp.substring(0, 2))
                        : null;
                    if (month == null || month < 1 || month > 12) {
                      err.value = 'Enter a valid expiry date (MM/YY).';
                      return;
                    }
                    if (cvvCtrl.text.length < 3) {
                      err.value = 'Enter the 3 or 4 digit CVV.';
                      return;
                    }

                    final brand = digits.startsWith('4')
                        ? 'Visa'
                        : (digits.startsWith('5') || digits.startsWith('2'))
                        ? 'Mastercard'
                        : 'Card';

                    setState(() {
                      _savedCards.add({
                        'title':
                        '$brand ending in ${digits.substring(digits.length - 4)}',
                        'expiry': exp,
                        'icon': Icons.credit_card_rounded,
                        'isDefault': false,
                      });
                      // Select the card that was just added
                      _selectedMethod = _savedCards.length;
                    });
                    Navigator.pop(ctx);
                    _toast('Card added successfully!');
                  },
                  child: const Text(
                    'SAVE & USE CARD',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top-up sheet (quick amounts + live new balance)
  // ---------------------------------------------------------------------------
  void _showTopUpWalletModal() {
    final shortfall = widget.amount - _walletBalance;
    final amtCtrl = TextEditingController(text: '10000');
    final err = ValueNotifier<String?>(null);
    const quick = [5000, 10000, 20000, 50000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 14, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lemon,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Up Sekure Wallet',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Current balance ${_fmt(_walletBalance)}',
                          style: const TextStyle(
                              fontSize: 12.5, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => err.value = null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                decoration:
                _deco('Amount', Icons.money_rounded, prefixText: '₦ '),
              ),
              const SizedBox(height: 12),

              // Quick amounts
              AnimatedBuilder(
                animation: amtCtrl,
                builder: (context, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final q in quick)
                        GestureDetector(
                          onTap: () {
                            amtCtrl.text = '$q';
                            amtCtrl.selection = TextSelection.collapsed(
                                offset: amtCtrl.text.length);
                            err.value = null;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: amtCtrl.text == '$q'
                                  ? AppColors.black
                                  : const Color(0xFFF6F5EF),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: amtCtrl.text == '$q'
                                    ? AppColors.black
                                    : Colors.black12,
                              ),
                            ),
                            child: Text(
                              _fmtWhole(q.toDouble()),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: amtCtrl.text == '$q'
                                    ? AppColors.lemon
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              if (shortfall > 0) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    amtCtrl.text = '${shortfall.ceil()}';
                    amtCtrl.selection = TextSelection.collapsed(
                        offset: amtCtrl.text.length);
                    err.value = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lemon.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.lemon.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            size: 18, color: AppColors.black),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You need ${_fmtWhole(shortfall.ceilToDouble())} more to pay for this waybill. Tap to add that amount.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // New balance preview
              AnimatedBuilder(
                animation: amtCtrl,
                builder: (context, _) {
                  final add = double.tryParse(amtCtrl.text) ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5EF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New balance',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          _fmt(_walletBalance + add),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _inlineError(err),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
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
                  onPressed: () {
                    final added = double.tryParse(amtCtrl.text) ?? 0;
                    if (added <= 0) {
                      err.value = 'Enter an amount greater than ₦0.';
                      return;
                    }
                    setState(() => _walletBalance += added);
                    Navigator.pop(ctx);
                    _toast(
                        'Wallet successfully credited with ${_fmtWhole(added)}!');
                  },
                  child: const Text(
                    'CONFIRM TOP UP',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == 0 && _walletBalance < widget.amount) {
      _toast('Insufficient wallet balance. Please top up or choose another method.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _loading = false);

    if (_selectedMethod == 0) {
      setState(() => _walletBalance -= widget.amount);
    }

    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FindingCourierScreen(waybillId: widget.waybillId),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with amount
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
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
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lemon.withValues(alpha: 0.38),
                    AppColors.lemon.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
                                color: Colors.white.withValues(alpha: 0.18)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Secure Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.lemon.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: AppColors.lemon.withValues(alpha: 0.55)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded,
                                color: AppColors.lemon, size: 13),
                            SizedBox(width: 6),
                            Text(
                              'ENCRYPTED',
                              style: TextStyle(
                                color: AppColors.lemon,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'TOTAL WAYBILL FARE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fmt(widget.amount),
                    style: const TextStyle(
                      color: AppColors.lemon,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 7),
                        Text(
                          'Waybill ${widget.waybillId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
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
  // Wallet card
  // ---------------------------------------------------------------------------
  Widget _buildWalletCard() {
    final selected = _selectedMethod == 0;
    final short = _walletShort;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232323), AppColors.black],
          ),
          border: Border.all(
            color: selected ? AppColors.lemon : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lemon.withValues(alpha: 0.22),
                      AppColors.lemon.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.lemon,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.black,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'SEKURE WALLET',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      _SelectDot(selected: selected, onDark: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Available balance',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _fmt(_walletBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              short
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_rounded,
                              size: 16,
                              color: short
                                  ? const Color(0xFFFF8A80)
                                  : AppColors.lemon,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                short
                                    ? '${_fmtWhole((widget.amount - _walletBalance).ceilToDouble())} short for this waybill'
                                    : 'Covers this waybill',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: short
                                      ? const Color(0xFFFF8A80)
                                      : AppColors.lemon,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showTopUpWalletModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.lemon,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 17, color: AppColors.black),
                              SizedBox(width: 4),
                              Text(
                                'Top Up',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
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

  // ---------------------------------------------------------------------------
  // Bottom bar
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 16, color: Colors.black45),
                const SizedBox(width: 8),
                const Text(
                  'Paying with',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _selectedLabel,
                      key: ValueKey(_selectedLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.lemon,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _loading ? null : _processPayment,
                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.lemon,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'PAY ${_fmt(widget.amount)} NOW',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: [
                const _SectionLabel('WALLET'),
                const SizedBox(height: 12),
                _buildWalletCard(),

                const SizedBox(height: 26),

                Row(
                  children: [
                    const Expanded(child: _SectionLabel('SAVED CARDS')),
                    GestureDetector(
                      onTap: _showAddCardModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.lemon.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 16, color: AppColors.black),
                            SizedBox(width: 4),
                            Text(
                              'Add Card',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                for (var i = 0; i < _savedCards.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MethodTile(
                      selected: _selectedMethod == i + 1,
                      onTap: () => setState(() => _selectedMethod = i + 1),
                      leading: _BrandBadge(
                        brand: _brandOf(_savedCards[i]['title'] as String),
                        fallbackIcon: _savedCards[i]['icon'] as IconData,
                      ),
                      title: _savedCards[i]['title'] as String,
                      subtitle: 'Expires ${_savedCards[i]['expiry']}',
                      badge: (_savedCards[i]['isDefault'] as bool) ? 'DEFAULT' : null,
                    ),
                  ),

                const SizedBox(height: 16),
                const _SectionLabel('OTHER WAYS TO PAY'),
                const SizedBox(height: 12),

                _MethodTile(
                  selected: _selectedMethod == _bankIndex,
                  onTap: () => setState(() => _selectedMethod = _bankIndex),
                  leading: Container(
                    width: 46,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.lemon.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_rounded,
                        color: AppColors.black, size: 20),
                  ),
                  title: 'Instant Bank Transfer',
                  subtitle: 'USSD / Virtual Account',
                ),

                const SizedBox(height: 22),

                // Reassurance note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lemon.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.lemon.withValues(alpha: 0.7)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_user_rounded,
                          color: AppColors.black, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your payment details are encrypted and processed securely.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small widgets
// -----------------------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
          color: Colors.black45,
        ),
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  final bool selected;
  final bool onDark;
  const _SelectDot({required this.selected, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final on = onDark ? AppColors.lemon : AppColors.black;
    final off = onDark ? Colors.white30 : Colors.black26;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? on : Colors.transparent,
        border: Border.all(color: selected ? on : off, width: 1.8),
      ),
      child: selected
          ? Icon(
        Icons.check_rounded,
        size: 16,
        color: onDark ? AppColors.black : AppColors.lemon,
      )
          : null,
    );
  }
}

class _BrandBadge extends StatelessWidget {
  final String brand;
  final IconData fallbackIcon;
  const _BrandBadge({required this.brand, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: brand.isEmpty
          ? Icon(fallbackIcon, color: AppColors.lemon, size: 20)
          : Text(
        brand,
        style: const TextStyle(
          color: AppColors.lemon,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final String? badge;

  const _MethodTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.badge,
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
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.black
                : Colors.black.withValues(alpha: 0.06),
            width: selected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
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
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _SelectDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Input formatters
// -----------------------------------------------------------------------------
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) digits = digits.substring(0, 16);

    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    var text = digits;
    if (digits.length > 2) {
      text = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}