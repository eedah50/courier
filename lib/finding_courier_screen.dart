import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';
import 'live_tracking_screen.dart';

class FindingCourierScreen extends StatefulWidget {
  final String waybillId;

  const FindingCourierScreen({super.key, required this.waybillId});

  @override
  State<FindingCourierScreen> createState() => _FindingCourierScreenState();
}

class _FindingCourierScreenState extends State<FindingCourierScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  int _secondsElapsed = 0;
  Timer? _timer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    // Automatically match courier after 5 seconds for smooth demo flow
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LiveTrackingScreen(
            waybillId: widget.waybillId,
            courierName: 'Ibrahim Olatunji',
            courierPhone: '+234 803 445 9920',
            vehicleInfo: 'Honda Ace 125 • LAG-492-IKJ',
            rating: 4.9,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  String get _elapsedLabel {
    final m = _secondsElapsed ~/ 60;
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _cancelSearch() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lemon,
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: AppColors.black,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cancel courier search?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We are still looking for a verified courier near your pickup location. Are you sure you want to cancel this request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13.5,
                  height: 1.45,
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
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'KEEP SEARCHING',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // pop dialog
                  Navigator.pop(context); // pop screen back to dashboard
                },
                child: const Text(
                  'Yes, cancel request',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
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
  // Radar
  // ---------------------------------------------------------------------------
  Widget _buildRadar() {
    return SizedBox(
      width: 300,
      height: 300,
      child: AnimatedBuilder(
        animation: _animCtrl,
        builder: (context, _) {
          final pulse = 1 + 0.05 * math.sin(_animCtrl.value * math.pi * 4);
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: _RadarPainter(_animCtrl.value),
              ),
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.lemon, AppColors.yellow],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lemon.withValues(alpha: 0.55),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: AppColors.black,
                    size: 42,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Progress steps
  // ---------------------------------------------------------------------------
  Widget _buildSteps() {
    final s = _secondsElapsed;
    final states = [
      _StepState.done,
      s >= 2 ? _StepState.done : _StepState.active,
      s >= 2 ? _StepState.active : _StepState.pending,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          _StepRow(
            state: states[0],
            title: 'Request sent',
            subtitle: 'Your waybill is confirmed and paid',
          ),
          _StepRow(
            state: states[1],
            title: 'Notifying verified riders',
            subtitle: 'Riders near your pickup are being alerted',
          ),
          _StepRow(
            state: states[2],
            title: 'Matching your courier',
            subtitle: 'Assigning the closest available rider',
            isLast: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancelSearch();
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            // Ambient lemon glows
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
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
            Positioned(
              bottom: -140,
              right: -100,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lemon.withValues(alpha: 0.14),
                      AppColors.lemon.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar: waybill chip + close
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                  color: AppColors.lemon, size: 15),
                              const SizedBox(width: 7),
                              Text(
                                widget.waybillId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Cancel request',
                          icon: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.10),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18)),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                          ),
                          onPressed: _cancelSearch,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        children: [
                          _buildRadar(),
                          const SizedBox(height: 8),

                          // Title with animated dots
                          AnimatedBuilder(
                            animation: _animCtrl,
                            builder: (context, _) {
                              final dots =
                                  '.' * ((_animCtrl.value * 4).floor() % 4);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Finding your courier',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      dots,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.lemon,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sending your request to verified riders near your pickup location.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Elapsed timer pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.lemon.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.lemon.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined,
                                    color: AppColors.lemon, size: 16),
                                const SizedBox(width: 7),
                                Text(
                                  'Searching · $_elapsedLabel',
                                  style: const TextStyle(
                                    color: AppColors.lemon,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          _buildSteps(),
                          const SizedBox(height: 16),

                          // Friendly tip
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Colors.white38, size: 17),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Stay on this screen. We will take you to live tracking as soon as a courier accepts.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cancel button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      onPressed: _cancelSearch,
                      child: const Text(
                        'CANCEL REQUEST',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step row
// -----------------------------------------------------------------------------
enum _StepState { done, active, pending }

class _StepRow extends StatelessWidget {
  final _StepState state;
  final String title;
  final String subtitle;
  final bool isLast;

  const _StepRow({
    required this.state,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;

    Widget dot;
    if (done) {
      dot = Container(
        key: const ValueKey('done'),
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lemon,
        ),
        child: const Icon(Icons.check_rounded, size: 16, color: AppColors.black),
      );
    } else if (active) {
      dot = Container(
        key: const ValueKey('active'),
        width: 26,
        height: 26,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lemon.withValues(alpha: 0.5)),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppColors.lemon,
        ),
      );
    } else {
      dot = Container(
        key: const ValueKey('pending'),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.6),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: dot,
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: done
                    ? AppColors.lemon.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.12),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: active
                        ? Colors.white
                        : (done ? Colors.white70 : Colors.white38),
                  ),
                  child: Text(title),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.white60 : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Radar: rings, expanding pulses, rotating sweep, riders lighting up as the
// sweep passes over them.
// -----------------------------------------------------------------------------
class _RadarPainter extends CustomPainter {
  final double t; // 0..1 loop

  _RadarPainter(this.t);

  // [angle (rad), radius at a 150px radar]
  static const List<List<double>> _riders = [
    [0.6, 70],
    [1.5, 105],
    [2.3, 60],
    [3.2, 120],
    [4.1, 88],
    [5.0, 112],
    [5.7, 52],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    final scale = maxR / 150;
    final rect = Rect.fromCircle(center: c, radius: maxR);

    // Soft inner glow
    canvas.drawCircle(
      c,
      maxR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.lemon.withValues(alpha: 0.16),
            AppColors.lemon.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    // Static rings + crosshair
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.09);
    for (final r in [maxR * 0.36, maxR * 0.68, maxR - 1]) {
      canvas.drawCircle(c, r, ring);
    }
    final cross = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawLine(Offset(c.dx - maxR, c.dy), Offset(c.dx + maxR, c.dy), cross);
    canvas.drawLine(Offset(c.dx, c.dy - maxR), Offset(c.dx, c.dy + maxR), cross);

    // Expanding pulses
    for (var i = 0; i < 3; i++) {
      final p = (t * 1.0 + i / 3) % 1.0;
      canvas.drawCircle(
        c,
        42 + p * (maxR - 42),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.lemon.withValues(alpha: (1 - p) * 0.45),
      );
    }

    // Rotating sweep
    final a = t * 2 * math.pi;
    canvas.drawCircle(
      c,
      maxR,
      Paint()
        ..shader = SweepGradient(
          colors: [
            AppColors.lemon.withValues(alpha: 0),
            AppColors.lemon.withValues(alpha: 0),
            AppColors.lemon.withValues(alpha: 0.38),
          ],
          stops: const [0, 0.72, 1],
          transform: GradientRotation(a),
        ).createShader(rect),
    );
    canvas.drawLine(
      c,
      c + Offset(math.cos(a), math.sin(a)) * maxR,
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.lemon.withValues(alpha: 0.8),
    );

    // Riders (light up as the sweep passes, then fade)
    for (final r in _riders) {
      final ang = r[0];
      final pos = c + Offset(math.cos(ang), math.sin(ang)) * (r[1] * scale);
      final d = (a - ang) % (2 * math.pi);
      final b = d < math.pi * 1.2 ? 1 - d / (math.pi * 1.2) : 0.0;

      canvas.drawCircle(
        pos,
        11,
        Paint()..color = AppColors.lemon.withValues(alpha: 0.22 * b),
      );
      canvas.drawCircle(
        pos,
        4.5,
        Paint()..color = AppColors.lemon.withValues(alpha: 0.28 + 0.72 * b),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}