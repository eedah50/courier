import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

enum _Phase { idle, verifying, success }

// Success palette (lemon yellow, matches the app theme)
const Color _kSuccess = AppColors.lemon;
const Color _kSuccessLight = Color(0xFFFFF59D);

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendTimer = 30;
  Timer? _timer;
  _Phase _phase = _Phase.idle;

  static const double _sceneHeight = 120;

  // Loops while "verifying": boxes jump in a staggered wave with a glow.
  late final AnimationController _waveCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  // Plays once on success:
  // boxes flip -> bike rides in (bouncing) -> brakes -> parcel drops & bounces
  // -> check badge pops -> confetti.
  late final AnimationController _successCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveCtrl.dispose();
    _successCtrl.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _verifyOtp() async {
    if (_phase != _Phase.idle) return; // ignore double triggers

    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      _toast('Please enter the 4-digit verification code.');
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    // 1) Verifying: button shrinks to a circle, boxes ripple in a wave.
    setState(() => _phase = _Phase.verifying);
    _waveCtrl.repeat();

    await Future.delayed(const Duration(milliseconds: 1800)); // your API call
    if (!mounted) return;

    // 2) Success: boxes flip, delivery bike rides in and drops the parcel.
    _waveCtrl.stop();
    setState(() => _phase = _Phase.success);
    HapticFeedback.mediumImpact();
    await _successCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.onVerified();
  }

  // ---------------------------------------------------------------------------
  // OTP box with wave (verifying) + 3D flip (success)
  // ---------------------------------------------------------------------------
  Widget _buildBox(int i) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveCtrl, _successCtrl]),
      builder: (context, _) {
        double lift = 0, scale = 1, glow = 0;

        if (_phase == _Phase.verifying) {
          final t = (_waveCtrl.value - i * 0.12 + 1.0) % 1.0;
          glow = math.sin(t * math.pi);
          lift = -12 * glow;
          scale = 1 + 0.08 * glow;
        }

        double flip = 0;
        if (_phase == _Phase.success) {
          flip = Interval(
            i * 0.04,
            i * 0.04 + 0.20,
            curve: Curves.easeInOutCubic,
          ).transform(_successCtrl.value);
        }
        final angle = flip * math.pi;
        final showBack = angle > math.pi / 2;

        final decoration = showBack
            ? BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kSuccessLight, _kSuccess],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kSuccess.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        )
            : BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(Colors.black12, AppColors.orange, glow)!,
            width: 1 + glow,
          ),
          boxShadow: glow > 0
              ? [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.35 * glow),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        );

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.scale(
            scale: scale,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: Container(
                width: 64,
                height: 68,
                decoration: decoration,
                alignment: Alignment.center,
                child: showBack
                // counter-rotate so the icon isn't mirrored
                    ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.black,
                    size: 32,
                  ),
                )
                    : TextFormField(
                  key: ValueKey('otp_$i'),
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  enabled: _phase == _Phase.idle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 3) {
                      _focusNodes[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                    if (i == 3 && val.isNotEmpty) {
                      _verifyOtp();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Button (pill -> spinner circle) that grows into the delivery scene
  // ---------------------------------------------------------------------------
  Widget _buildActionButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        final idle = _phase == _Phase.idle;
        final success = _phase == _Phase.success;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: fullWidth,
          height: success ? _sceneHeight : 52,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Bike delivery scene
              if (success)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _sceneHeight,
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: _successCtrl,
                      builder: (context, _) => CustomPaint(
                        painter: _DeliveryPainter(_successCtrl.value),
                      ),
                    ),
                  ),
                ),

              // Verify button (fades away on success)
              IgnorePointer(
                ignoring: !idle,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: success ? 0 : 1,
                  child: GestureDetector(
                    onTap: idle ? _verifyOtp : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                      width: idle ? fullWidth : 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.lemon,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lemon.withValues(alpha: 0.5),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: idle
                          ? const Text(
                        'Verify',
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      )
                          : (_phase == _Phase.verifying
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.black,
                        ),
                      )
                          : const SizedBox.shrink()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final idle = _phase == _Phase.idle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Hero Header in Lemon Yellow & Orange Gradient
            Container(
              height: size.height * 0.38,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lemon, AppColors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: idle ? () => Navigator.pop(context) : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.black,
                            size: 28,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Verification Code',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Code sent to ${widget.phoneNumber.isEmpty ? "your contact number" : widget.phoneNumber}.',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // Overlapping Card
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forgot password ?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'No worries, it happens! Just enter the code associated with your account.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40), // extra room for the wave lift

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, _buildBox),
                    ),

                    const SizedBox(height: 32),

                    _buildActionButton(),

                    const SizedBox(height: 24),

                    // Success message (bounces in) / Resend link (fades out)
                    SizedBox(
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: idle ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: !idle,
                              child: _resendTimer > 0
                                  ? Text(
                                "Didn't received code? Resend in ${_resendTimer}s",
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 13),
                              )
                                  : GestureDetector(
                                onTap: () {
                                  _startResendTimer();
                                  _toast(
                                      'A new 4-digit verification code has been sent!');
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: "Didn't received code? ",
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13),
                                    children: const [
                                      TextSpan(
                                        text: 'Resend',
                                        style: TextStyle(
                                          color: AppColors.orange,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _successCtrl,
                            builder: (context, _) {
                              final fade = Interval(0.85, 0.95,
                                  curve: Curves.easeOut)
                                  .transform(_successCtrl.value);
                              final bounce = Interval(0.85, 1.0,
                                  curve: Curves.elasticOut)
                                  .transform(_successCtrl.value);
                              return Opacity(
                                opacity: fade,
                                child: Transform.translate(
                                  offset: Offset(0, 14 * (1 - bounce)),
                                  child: const Text(
                                    'Code verified successfully!',
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            },
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
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Delivery scene: courier on a bike rides in (bouncing), brakes with a little
// stoppie, drops the parcel which bounces on the road, then a check badge pops.
// Everything is drawn in code, no assets needed. `t` is the 0..1 progress of
// the whole success controller.
// -----------------------------------------------------------------------------
class _DeliveryPainter extends CustomPainter {
  final double t;

  _DeliveryPainter(this.t);

  static const double _r = 13; // wheel radius

  double _iv(double a, double b, [Curve curve = Curves.linear]) =>
      Interval(a, b, curve: curve).transform(t);

  double _lerp(double a, double b, double v) => a + (b - a) * v;

  Paint _line(Color c, double width) => Paint()
    ..color = c
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = h - 14;

    // ---- Road ---------------------------------------------------------------
    final roadFade = _iv(0.02, 0.12);
    canvas.drawLine(
      Offset(0, ground),
      Offset(w, ground),
      Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.18 * roadFade),
            Colors.black.withValues(alpha: 0.18 * roadFade),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0, 0.12, 0.88, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    final dash = _line(Colors.black.withValues(alpha: 0.08 * roadFade), 2);
    for (double x = 14; x < w - 20; x += 38) {
      canvas.drawLine(Offset(x, ground + 8), Offset(x + 16, ground + 8), dash);
    }

    // ---- Ride-in (with bounce) ---------------------------------------------
    final rideRaw = _iv(0.12, 0.62);
    final ride = Curves.easeOutCubic.transform(rideRaw);
    final stopX = w / 2 - 34;
    final bikeX = _lerp(-70, stopX, ride);
    final speed = math.pow(1 - rideRaw, 2).toDouble();
    final amp = 0.75 * speed + 0.25 * (1 - rideRaw);
    final phase = rideRaw * math.pi * 2 * 16;
    final bob = math.sin(phase).abs() * 5 * amp; // frame hop
    final boxBob = math.sin(phase - 0.9).abs() * 4 * amp; // parcel lags behind
    final wheelLift = bob * 0.5;
    final wheelAngle = bikeX / _r;

    // Shadow (shrinks while the bike hops)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bikeX, ground + 1),
        width: 70 * (1 - bob * 0.04),
        height: 6,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.10 * (1 - bob * 0.05)),
    );

    // Speed lines
    if (speed > 0.02) {
      for (var i = 0; i < 4; i++) {
        final y = ground - 14 - i * 9;
        final x = bikeX - 52 - i * 5;
        final len = (14 + 8 * i) * speed * 1.5;
        canvas.drawLine(
          Offset(x - len, y),
          Offset(x, y),
          _line(AppColors.orange.withValues(alpha: 0.5 * speed), 2.5),
        );
      }
    }

    // Dust puffs while braking
    final dust = _iv(0.62, 0.85);
    if (dust > 0 && dust < 1) {
      for (var i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(bikeX - 30 - i * 6 - 14 * dust,
              ground - 4 - 10 * dust * (i % 2 + 1)),
          3 + 6 * dust,
          Paint()..color = Colors.black.withValues(alpha: 0.12 * (1 - dust)),
        );
      }
    }

    // ---- Bike (with brake "stoppie" wobble) ---------------------------------
    final dropU = _iv(0.68, 0.92);
    final brakeU = _iv(0.62, 0.82);
    final pitch =
        0.32 * math.exp(-3 * brakeU) * math.sin(3 * math.pi * brakeU);

    canvas.save();
    canvas.translate(bikeX, ground);
    canvas.translate(22, 0); // pivot around the front tyre
    canvas.rotate(pitch);
    canvas.translate(-22, 0);
    _drawBike(
      canvas,
      bob: bob,
      boxBob: boxBob,
      wl: wheelLift,
      wheelAngle: wheelAngle,
      showBox: dropU <= 0,
    );
    canvas.restore();

    // ---- Parcel drop with bounce -------------------------------------------
    final startX = bikeX - 25;
    final targetX = bikeX + 70;
    if (dropU > 0) {
      final px = _lerp(startX, targetX, Curves.easeOutCubic.transform(dropU));
      final firstFall = math.min(dropU / 0.364, 1.0);
      final height = 27 * (1 - Curves.bounceOut.transform(dropU)) +
          28 * math.sin(math.pi * firstFall);
      final tilt = 0.5 * math.sin(math.pi * firstFall);

      // parcel shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(px, ground + 1),
          width: 26 * (1 - (height / 90).clamp(0.0, 0.6)),
          height: 5,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );

      canvas.save();
      canvas.translate(px, ground - 9 - height);
      canvas.rotate(tilt);
      _drawBox(canvas, Rect.fromCenter(
          center: Offset.zero, width: 24, height: 18));
      canvas.restore();
    }

    // ---- Check badge pops above the parcel ---------------------------------
    final badge = _iv(0.88, 1.0, Curves.elasticOut);
    if (badge > 0) {
      canvas.save();
      canvas.translate(targetX, ground - 48);
      canvas.scale(badge);
      canvas.drawCircle(Offset.zero, 13, Paint()..color = _kSuccess);
      final check = Path()
        ..moveTo(-5.5, 0.5)
        ..lineTo(-1.5, 4.5)
        ..lineTo(5.5, -3.5);
      canvas.drawPath(check, _line(AppColors.black, 3));
      canvas.restore();
    }

    // ---- Confetti when the parcel first lands ------------------------------
    final cu = _iv(0.77, 1.0, Curves.easeOutCubic);
    if (cu > 0 && cu < 1) {
      for (var i = 0; i < 12; i++) {
        final a = i * 2 * math.pi / 12 + 0.3;
        final d = 12 + 46 * cu;
        final pos = Offset(
          targetX + math.cos(a) * d,
          ground - 12 + math.sin(a) * d * 0.8 + 22 * cu * cu,
        );
        canvas.drawCircle(
          pos,
          3.2 * (1 - cu) + 0.4,
          Paint()
            ..color = (i.isEven ? _kSuccess : _kSuccessLight)
                .withValues(alpha: 1 - cu),
        );
      }
    }
  }

  // Bike + rider. Origin = ground contact point under the bike centre.
  void _drawBike(
      Canvas canvas, {
        required double bob,
        required double boxBob,
        required double wl,
        required double wheelAngle,
        required bool showBox,
      }) {
    const r = _r;
    final rear = Offset(-22, -r - wl);
    final front = Offset(22, -r - wl);
    final bb = Offset(-3, -11 - wl);
    final seat = Offset(-9, -31 - bob);
    final head = Offset(15, -33 - bob);
    final hip = Offset(-8, -35 - bob);
    final shoulder = Offset(3, -53 - bob);
    final headC = Offset(7, -61 - bob);
    final hand = Offset(16, -40 - bob);

    final pa = wheelAngle * 0.9;
    Offset pedal(double a) => bb + Offset(math.cos(a), math.sin(a)) * 6.5;

    // far leg + far crank
    canvas.drawLine(bb, pedal(pa + math.pi), _line(Colors.black45, 2.5));
    _leg(canvas, hip, pedal(pa + math.pi), Colors.black54);

    // wheels
    for (final c in [rear, front]) {
      canvas.drawCircle(c, r, Paint()..color = Colors.white);
      canvas.drawCircle(c, r, _line(AppColors.black, 3.5));
      final spoke = _line(Colors.black45, 1.2);
      for (var i = 0; i < 5; i++) {
        final a = wheelAngle + i * 2 * math.pi / 5;
        canvas.drawLine(
            c, c + Offset(math.cos(a), math.sin(a)) * (r - 2), spoke);
      }
      canvas.drawCircle(c, 2.2, Paint()..color = AppColors.black);
    }

    // rack + parcel
    final rackY = -27 - bob * 0.6;
    canvas.drawLine(
        Offset(-38, rackY), Offset(-12, rackY), _line(AppColors.black, 2.5));
    canvas.drawLine(rear, Offset(-30, rackY), _line(AppColors.black, 2));
    if (showBox) {
      _drawBox(canvas, Rect.fromLTWH(-37, rackY - 18 - boxBob, 24, 18));
    }

    // frame
    final frame = _line(AppColors.black, 3);
    canvas.drawLine(rear, bb, frame);
    canvas.drawLine(rear, seat, frame);
    canvas.drawLine(bb, seat, frame);
    canvas.drawLine(bb, head, frame);
    canvas.drawLine(head, front, frame);
    canvas.drawLine(seat, head, _line(AppColors.orange, 3));
    // saddle + handlebar
    canvas.drawLine(Offset(-14, seat.dy - 2.5), Offset(-5, seat.dy - 2.5),
        _line(AppColors.black, 4));
    canvas.drawLine(head, Offset(12, head.dy - 6), _line(AppColors.black, 2.5));
    canvas.drawLine(Offset(12, head.dy - 6), Offset(18, head.dy - 5),
        _line(AppColors.black, 3));

    // near crank + leg
    canvas.drawLine(bb, pedal(pa), _line(Colors.black54, 2.5));
    _leg(canvas, hip, pedal(pa), AppColors.black);

    // torso, arm, head + helmet
    canvas.drawLine(hip, shoulder, _line(AppColors.orange, 8));
    canvas.drawLine(shoulder, hand, _line(AppColors.orange, 3.5));
    canvas.drawCircle(headC, 5.5, Paint()..color = AppColors.black);
    canvas.drawArc(
      Rect.fromCircle(center: headC, radius: 6.5),
      math.pi,
      math.pi,
      true,
      Paint()..color = AppColors.lemon,
    );
  }

  // Two-bone IK leg (hip -> knee -> pedal).
  void _leg(Canvas canvas, Offset hip, Offset pedal, Color color) {
    const l = 17.0;
    final d = pedal - hip;
    final dist = math.min(d.distance, 2 * l - 0.5);
    final base = math.atan2(d.dy, d.dx);
    final a = math.acos(dist / (2 * l));
    final knee = hip + Offset(math.cos(base - a), math.sin(base - a)) * l;
    final foot = hip + Offset(math.cos(base), math.sin(base)) * dist;

    final path = Path()
      ..moveTo(hip.dx, hip.dy)
      ..lineTo(knee.dx, knee.dy)
      ..lineTo(foot.dx, foot.dy);
    canvas.drawPath(path, _line(color, 4.5));
    canvas.drawLine(foot, foot + const Offset(5, 0), _line(color, 3));
  }

  // Delivery parcel: orange box with a lemon tape stripe.
  void _drawBox(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = AppColors.orange);
    canvas.drawRect(
      Rect.fromCenter(center: rect.center, width: 5, height: rect.height),
      Paint()..color = AppColors.lemon,
    );
    canvas.drawRRect(rrect, _line(AppColors.black, 1.8));
  }

  @override
  bool shouldRepaint(covariant _DeliveryPainter old) => old.t != t;
}