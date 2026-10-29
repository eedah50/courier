import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'courier_navigation_dropoff_screen.dart';

class CourierPickupConfirmationScreen extends StatefulWidget {
  final String orderId;
  final int payout;

  const CourierPickupConfirmationScreen({
    super.key,
    required this.orderId,
    required this.payout,
  });

  @override
  State<CourierPickupConfirmationScreen> createState() =>
      _CourierPickupConfirmationScreenState();
}

class _CourierPickupConfirmationScreenState
    extends State<CourierPickupConfirmationScreen> {
  // ---- Palette (matches the live tracking screen) ----
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF7A7A72);
  static const _page = Color(0xFFF7F7F3);
  static const _line = Color(0xFFEAEAE3);
  static const _soft = Color(0xFFF6F5EF);
  static const _green = Color(0xFF10B981);

  bool _checkedSeal = false;
  bool _checkedFragile = false;
  bool _hasPhoto = false;

  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  bool get _codeDone => _codeController.text.length == 4;
  bool get _inspectDone => _checkedSeal;
  int get _doneCount =>
      (_inspectDone ? 1 : 0) + (_hasPhoto ? 1 : 0) + (_codeDone ? 1 : 0);
  bool get _ready => _doneCount == 3;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      setState(() {});
      if (_codeDone) _codeFocus.unfocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.yellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _confirm() {
    if (!_ready) {
      final missing = <String>[
        if (!_inspectDone) 'confirm the security seal',
        if (!_hasPhoto) 'take the package photo',
        if (!_codeDone) 'enter the 4-digit code',
      ];
      _toast('Still to do: ${missing.join(', ')}.');
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CourierNavigationDropoffScreen(
          orderId: widget.orderId,
          payout: widget.payout,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _page,
        bottomNavigationBar: _bottomBar(),
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  _summaryCard(),
                  const SizedBox(height: 26),
                  _sectionTitle('1', 'Inspect the package',
                      'Check it before you accept it.', _inspectDone),
                  const SizedBox(height: 12),
                  _checklistCard(),
                  const SizedBox(height: 26),
                  _sectionTitle('2', 'Photograph the package',
                      'Proof of its condition at pickup.', _hasPhoto),
                  const SizedBox(height: 12),
                  _photoCard(),
                  const SizedBox(height: 26),
                  _sectionTitle('3', 'Enter the sender’s code',
                      'The sender reads out 4 digits.', _codeDone),
                  const SizedBox(height: 12),
                  _codeCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER + SUMMARY
  // ---------------------------------------------------------------------------
  Widget _header() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.arrow_back_rounded, color: _ink, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Confirm pickup',
            style: TextStyle(
              color: _ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    const labels = ['Inspect', 'Photo', 'Code'];
    final done = [_inspectDone, _hasPhoto, _codeDone];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${widget.orderId}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${widget.payout}',
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Your payout for this delivery',
                      style: TextStyle(color: Colors.white60, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child:
                const Icon(Icons.inventory_2_rounded, color: _ink, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        decoration: BoxDecoration(
                          color: done[i] ? AppColors.yellow : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: done[i] ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------
  Widget _sectionTitle(String n, String title, String sub, bool done) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? _green : AppColors.yellow,
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text(n,
              style: const TextStyle(
                  color: _ink, fontWeight: FontWeight.w900, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _ink,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 1),
              Text(sub, style: const TextStyle(color: _muted, fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration({Color? border}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: border ?? _line, width: border == null ? 1 : 1.6),
    boxShadow: const [
      BoxShadow(
          color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4)),
    ],
  );

  // ---- 1. Checklist ----
  Widget _checklistCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _checkRow(
            value: _checkedSeal,
            title: 'Security seal is intact',
            subtitle: 'No tears, tampering or loose tape',
            icon: Icons.verified_user_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _checkedSeal = !_checkedSeal);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: _line),
          _checkRow(
            value: _checkedFragile,
            title: 'Handling instructions read',
            subtitle: 'Fragile or this-way-up labels · optional',
            icon: Icons.wine_bar_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _checkedFragile = !_checkedFragile);
            },
          ),
        ],
      ),
    );
  }

  Widget _checkRow({
    required bool value,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _ink, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppColors.yellow : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: value ? _ink : Colors.black26,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, color: _ink, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ---- 2. Photo ----
  Widget _photoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(border: _hasPhoto ? _green : null),
      child: Column(
        children: [
          // Viewfinder / preview area
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasPhoto ? _green.withValues(alpha: 0.08) : _soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _hasPhoto
                  ? Column(
                key: const ValueKey('done'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text('Photo saved',
                      style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  const Text('pickup_package_scan.jpg',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ],
              )
                  : Column(
                key: const ValueKey('empty'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: _ink, width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: _ink, size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text('No photo yet',
                      style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  const Text('Fit the whole package in the frame',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _hasPhoto
                ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: Colors.black26, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retake photo',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                setState(() => _hasPhoto = false);
              },
            )
                : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: AppColors.yellow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('Take package photo',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _hasPhoto = true);
                _toast('Package photo saved.');
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---- 3. Code ----
  Widget _codeCard() {
    final code = _codeController.text;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(border: _codeDone ? _green : null),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final filled = i < code.length;
              final active = _codeFocus.hasFocus && i == code.length.clamp(0, 3);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: (MediaQuery.of(context).size.width - 40 - 32 - 36) / 4,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _codeDone ? _green.withValues(alpha: 0.08) : _soft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _codeDone
                        ? _green
                        : active
                        ? AppColors.yellow
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  filled ? code[i] : '',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }),
          ),
          // Invisible field that captures the digits.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocus,
                keyboardType: TextInputType.number,
                maxLength: 4,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () => setState(() {}),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM BAR
  // ---------------------------------------------------------------------------
  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _ready
                        ? 'All set. You can start the delivery.'
                        : '$_doneCount of 3 steps done',
                    style: TextStyle(
                      color: _ready ? _green : _muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('₦${widget.payout}',
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ready ? AppColors.yellow : _soft,
                    foregroundColor: _ready ? _ink : _muted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _confirm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _ready
                            ? Icons.two_wheeler_rounded
                            : Icons.lock_outline_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Confirm pickup & start delivery',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}