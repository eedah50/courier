import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'courier_trip_completed_screen.dart';

class CourierDeliveryConfirmationScreen extends StatefulWidget {
  final String orderId;
  final int payout;

  const CourierDeliveryConfirmationScreen({
    super.key,
    required this.orderId,
    required this.payout,
  });

  @override
  State<CourierDeliveryConfirmationScreen> createState() =>
      _CourierDeliveryConfirmationScreenState();
}

class _CourierDeliveryConfirmationScreenState
    extends State<CourierDeliveryConfirmationScreen> {
  // ---- Palette (matches the tracking + pickup confirmation screens) ----
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF7A7A72);
  static const _page = Color(0xFFF7F7F3);
  static const _line = Color(0xFFEAEAE3);
  static const _soft = Color(0xFFF6F5EF);
  static const _green = Color(0xFF10B981);

  bool _hasPhotoProof = false;
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();

  bool get _otpDone => _otpController.text.length == 4;

  /// Either method is enough to complete the delivery.
  bool get _verified => _otpDone || _hasPhotoProof;

  String get _verifiedBy {
    if (_otpDone && _hasPhotoProof) return 'code and photo';
    if (_otpDone) return 'delivery code';
    return 'doorstep photo';
  }

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      setState(() {});
      if (_otpDone) _otpFocus.unfocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
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

  void _complete() {
    if (!_verified) {
      _toast('Enter the recipient’s code or take a doorstep photo.');
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CourierTripCompletedScreen(
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
                  _statusCard(),
                  const SizedBox(height: 26),
                  _methodTitle(
                    icon: Icons.pin_rounded,
                    title: 'Delivery code',
                    sub: 'The recipient reads out 4 digits.',
                    done: _otpDone,
                  ),
                  const SizedBox(height: 12),
                  _codeCard(),
                  const SizedBox(height: 18),
                  _orDivider(),
                  const SizedBox(height: 18),
                  _methodTitle(
                    icon: Icons.photo_camera_rounded,
                    title: 'Doorstep photo',
                    sub: 'Use this if the recipient has no code.',
                    done: _hasPhotoProof,
                  ),
                  const SizedBox(height: 12),
                  _photoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER + STATUS
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
            'Confirm delivery',
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

  Widget _statusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                      'Yours once the delivery is confirmed',
                      style: TextStyle(color: Colors.white60, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _verified ? _green : AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _verified ? Icons.check_rounded : Icons.home_rounded,
                  color: _verified ? Colors.white : _ink,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _verified
                      ? Icons.verified_rounded
                      : Icons.info_outline_rounded,
                  color: _verified ? _green : AppColors.yellow,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _verified
                        ? 'Verified with $_verifiedBy'
                        : 'Verify with a code or a photo to finish',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
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

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------
  Widget _methodTitle({
    required IconData icon,
    required String title,
    required String sub,
    required bool done,
  }) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: done ? _green : AppColors.yellow,
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            color: done ? Colors.white : _ink,
            size: 17,
          ),
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

  Widget _orDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _line, thickness: 1.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('or',
              style: TextStyle(
                  color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
        Expanded(child: Divider(color: _line, thickness: 1.5)),
      ],
    );
  }

  BoxDecoration _cardDecoration({Color? border}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
        color: border ?? _line, width: border == null ? 1 : 1.6),
    boxShadow: const [
      BoxShadow(
          color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4)),
    ],
  );

  // ---- Code ----
  Widget _codeCard() {
    final code = _otpController.text;
    final boxWidth = (MediaQuery.of(context).size.width - 40 - 32 - 36) / 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(border: _otpDone ? _green : null),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final filled = i < code.length;
              final active = _otpFocus.hasFocus && i == code.length.clamp(0, 3);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: boxWidth,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _otpDone ? _green.withValues(alpha: 0.08) : _soft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _otpDone
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
                controller: _otpController,
                focusNode: _otpFocus,
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

  // ---- Photo ----
  Widget _photoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(border: _hasPhotoProof ? _green : null),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasPhotoProof ? _green.withValues(alpha: 0.08) : _soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _hasPhotoProof
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
                  const Text('doorstep_proof_photo.jpg',
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
                  const Text('Show the parcel at the recipient’s door',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _hasPhotoProof
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
              onPressed: () => setState(() => _hasPhotoProof = false),
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
              label: const Text('Take doorstep photo',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _hasPhotoProof = true);
                _toast('Doorstep photo saved.');
              },
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
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
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
                    _verified
                        ? 'Verified. Ready to complete.'
                        : 'Code or photo needed',
                    style: TextStyle(
                      color: _verified ? _green : _muted,
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verified ? AppColors.yellow : _soft,
                    foregroundColor: _verified ? _ink : _muted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _complete,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _verified
                            ? Icons.payments_rounded
                            : Icons.lock_outline_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Complete delivery & claim earnings',
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