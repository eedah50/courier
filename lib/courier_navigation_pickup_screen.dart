import 'dart:math' as math;
import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'courier_pickup_confirmation_screen.dart';
import 'chat_screen.dart';
import 'theme.dart';

/// Courier Navigation Pickup colours
class _C {
  static const bg = Color(0xFFF6F5EF);
  static const ink = AppColors.black;
  static const lime = AppColors.lemon;
  static const muted = Color(0xFF6B6E64);
  static const green = Color(0xFF1B5E20);
  static const red = Color(0xFFD94545);
}

class CourierNavigationPickupScreen extends StatefulWidget {
  final String orderId;
  final int payout;
  final String senderName;
  final String senderPhone;
  final String pickupAddress;
  final String distance;

  const CourierNavigationPickupScreen({
    super.key,
    required this.orderId,
    required this.payout,
    this.senderName = 'Sarah Lee',
    this.senderPhone = '+234 802 111 2233',
    this.pickupAddress = '12 Ikeja City Mall, Lagos',
    this.distance = '2.4 km',
  });

  @override
  State<CourierNavigationPickupScreen> createState() => _CourierNavigationPickupScreenState();
}

class _CourierNavigationPickupScreenState extends State<CourierNavigationPickupScreen>
    with TickerProviderStateMixin {
  static const _totalKm = 2.4;
  static const _speedKmh = 22;
  static const _from = .20, _to = .90;

  bool _expanded = false;

  /// Endless 2s loop for pulses.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  /// Simulated rider progress to pickup point.
  late final AnimationController _ride = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  )..forward();

  @override
  void dispose() {
    _loop.dispose();
    _ride.dispose();
    super.dispose();
  }

  double get _progress => _from + (_to - _from) * _ride.value;
  double get _remainingKm => _totalKm * (1 - _progress);
  int get _eta => math.max(1, (_remainingKm / (_speedKmh / 60)).round());

  String get _initials => widget.senderName
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w[0])
      .join()
      .toUpperCase();

  String _clock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: _C.ink,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _call() {
    Clipboard.setData(ClipboardData(text: widget.senderPhone));
    _snack('Phone copied: ${widget.senderPhone}');
  }

  void _chat() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(
          orderId: widget.orderId,
          peerName: widget.senderName,
          peerRole: 'Sender',
          peerPhone: widget.senderPhone,
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: LayoutBuilder(builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _BasePainter()),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_loop, _ride]),
                  builder: (context, child) => _PickupMapLayer(
                    size: size,
                    top: pad.top + 84,
                    progress: _progress,
                    pulse: _loop.value,
                    etaText: '$_eta min',
                    pickupAddress: widget.pickupAddress,
                  ),
                ),
              ),
              Positioned(
                top: pad.top + 12,
                left: 16,
                right: 16,
                child: _header(),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12 + pad.bottom,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                        offset: Offset(0, 70 * (1 - v)), child: child),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: size.height * .65),
                    child: _sheet(),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------- Header
  Widget _header() {
    Widget round(IconData icon, VoidCallback onTap) => _Pressable(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: .07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: _C.ink),
          ),
        );

    return Row(
      children: [
        round(Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black.withValues(alpha: .07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                _PulseDot(p: _loop.value),
                const SizedBox(width: 8),
                const Text('PICKUP NAV',
                    style: TextStyle(
                        color: _C.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1)),
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.black12,
                ),
                Expanded(
                  child: Text(widget.orderId,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _C.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        round(Icons.my_location_rounded, () => _snack('Map centred on pickup location')),
      ],
    );
  }

  // ----------------------------------------------------------- Bottom sheet
  Widget _sheet() {
    final arrival = _clock(DateTime.now().add(Duration(minutes: _eta)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _expanded = !_expanded);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Arriving at pickup in',
                          style: TextStyle(
                              color: _C.muted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('$_eta min',
                          style: const TextStyle(
                              color: _C.ink,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              height: 1.05)),
                      const SizedBox(height: 2),
                      Text('Estimated pickup $arrival',
                          style: const TextStyle(
                              color: _C.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _C.lime,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.two_wheeler_rounded, size: 15, color: _C.ink),
                      SizedBox(width: 6),
                      Text('En route to pickup',
                          style: TextStyle(
                              color: _C.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _customerRow(),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _steps(),
                        const SizedBox(height: 18),
                        _stats(),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            if (!_expanded)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: _Pressable(
                    onTap: () => setState(() => _expanded = true),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pickup details',
                            style: TextStyle(
                                color: _C.muted,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5)),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_up_rounded,
                            color: _C.muted, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _customerRow() {
    Widget btn(IconData icon, VoidCallback onTap, {bool dark = true}) =>
        _Pressable(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: dark ? _C.ink : _C.lime,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: dark ? _C.lime : _C.ink, size: 21),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _C.lime),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _C.ink,
              child: Text(_initials,
                  style: const TextStyle(
                      color: _C.lime,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(widget.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _C.ink,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded,
                        size: 16, color: _C.green),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 15, color: Color(0xFFF5A300)),
                    const SizedBox(width: 3),
                    const Text('4.8',
                        style: TextStyle(
                            color: _C.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('Sender • ${widget.pickupAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _C.muted, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          btn(Icons.call_rounded, _call, dark: false),
          const SizedBox(width: 8),
          btn(Icons.chat_bubble_rounded, _chat),
        ],
      ),
    );
  }

  Widget _steps() {
    const labels = ['Accepted', 'Navigating', 'Arrived', 'Verified'];
    const cur = 1; // Navigating to pickup

    Widget dot(int i) {
      final done = i < cur, now = i == cur;
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? _C.ink : (now ? _C.lime : Colors.white),
          border: Border.all(
            color: done || now ? _C.ink : Colors.black26,
            width: now ? 2.2 : 1.4,
          ),
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 13, color: _C.lime)
            : null,
      );
    }

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= cur ? _C.ink : Colors.black12),
                      ),
                    ),
                    dot(i),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == labels.length - 1
                            ? Colors.transparent
                            : (i < cur ? _C.ink : Colors.black12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(labels[i],
                    style: TextStyle(
                        color: i <= cur ? _C.ink : _C.muted,
                        fontSize: 11,
                        fontWeight:
                            i == cur ? FontWeight.w900 : FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _stats() {
    Widget tile(String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: _C.muted, fontSize: 11.5)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: _C.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile('Distance left', '${_remainingKm.toStringAsFixed(1)} km'),
        const SizedBox(width: 10),
        tile('Trip Payout', '₦${widget.payout}'),
      ],
    );
  }

  Widget _actions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _Pressable(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CourierPickupConfirmationScreen(
                    orderId: widget.orderId,
                    payout: widget.payout,
                  ),
                ),
              );
            },
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _C.lime,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.ink, width: 1.5),
              ),
              child: const Text('ARRIVED AT PICKUP',
                  style: TextStyle(
                      color: _C.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Pressable(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: _C.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5)),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Map
Path _pickupRoutePath(Size s, double top) {
  final w = s.width;
  final h = math.max(160.0, s.height * .50 - top - 10);
  Offset p(double x, double y) => Offset(w * x, top + h * y);

  final a = p(.20, .90), b1 = p(.20, .70), b2 = p(.50, .80), c = p(.48, .55);
  final d1 = p(.45, .35), d2 = p(.70, .50), e = p(.68, .30);

  return Path()
    ..moveTo(a.dx, a.dy)
    ..cubicTo(b1.dx, b1.dy, b2.dx, b2.dy, c.dx, c.dy)
    ..cubicTo(d1.dx, d1.dy, d2.dx, d2.dy, e.dx, e.dy);
}

class _PickupMapLayer extends StatelessWidget {
  final Size size;
  final double top, progress, pulse;
  final String etaText, pickupAddress;
  const _PickupMapLayer({
    required this.size,
    required this.top,
    required this.progress,
    required this.pulse,
    required this.etaText,
    required this.pickupAddress,
  });

  Widget _centered(Offset at, Widget child, {Offset shift = const Offset(-.5, -.5)}) =>
      Positioned(
        left: at.dx,
        top: at.dy,
        child: FractionalTranslation(translation: shift, child: child),
      );

  Widget _label(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(t,
            style: const TextStyle(
                color: _C.ink, fontSize: 11.5, fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    final path = _pickupRoutePath(size, top);
    final metric = path.computeMetrics().first;
    final len = metric.length;
    final rider = metric.getTangentForOffset(len * progress)!.position;
    final end = metric.getTangentForOffset(len)!.position;
    final q = pulse;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RoutePainter(metric: metric, progress: progress),
          ),
        ),
        // Pickup Target Point, pulsing
        _centered(
          end,
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 34 + 50 * q,
                  height: 34 + 50 * q,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.lime.withValues(alpha: .55 * (1 - q)),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _C.lime,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.ink, width: 2.4),
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      size: 19, color: _C.ink),
                ),
              ],
            ),
          ),
        ),
        _centered(end, _label(pickupAddress), shift: const Offset(-.5, -1.35)),
        // Rider
        _centered(
          rider,
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44 + 36 * q,
                  height: 44 + 36 * q,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.ink.withValues(alpha: .22 * (1 - q)),
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _C.ink,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.lime, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _C.lime.withValues(alpha: .6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.two_wheeler_rounded,
                      size: 24, color: _C.lime),
                ),
              ],
            ),
          ),
        ),
        _centered(
          rider,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(etaText,
                style: const TextStyle(
                    color: _C.lime,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900)),
          ),
          shift: const Offset(-.5, -2.5),
        ),
      ],
    );
  }
}

class _BasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF4F4EF));

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-.24);

    const cell = 62.0;
    final span = math.max(size.width, size.height) * 1.3;
    final n = (span / cell).ceil();
    final rnd = math.Random(11);
    final paint = Paint();

    for (var i = -n; i <= n; i++) {
      for (var j = -n; j <= n; j++) {
        final r = rnd.nextDouble();
        if (r < .08) continue;
        paint.color = r < .17
            ? const Color(0xFFDCE8D2)
            : (r < .6 ? const Color(0xFFE6E6E0) : const Color(0xFFDCDCD5));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(i * cell + 5, j * cell + 5, cell - 10, cell - 10),
            const Radius.circular(5),
          ),
          paint,
        );
      }
    }

    final major = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    for (var i = -n; i <= n; i += 4) {
      canvas.drawLine(
          Offset(i * cell, -span), Offset(i * cell, span), major);
      canvas.drawLine(
          Offset(-span, i * cell), Offset(span, i * cell), major);
    }

    final river = Path()
      ..moveTo(-span, span * .18)
      ..quadraticBezierTo(-span * .2, -span * .05, span * .2, span * .12)
      ..quadraticBezierTo(span * .6, span * .28, span, span * .05);
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFCFE2EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RoutePainter extends CustomPainter {
  final PathMetric metric;
  final double progress;
  _RoutePainter({required this.metric, required this.progress});

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final full = metric.extractPath(0, metric.length);
    final done = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(full, _stroke(Colors.white, 13));
    canvas.drawPath(full, _stroke(_C.ink, 9));
    canvas.drawPath(full, _stroke(_C.lime, 6));
    canvas.drawPath(done, _stroke(Colors.white, 10));
    canvas.drawPath(done, _stroke(_C.ink, 7));
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.progress != progress;
}

class _PulseDot extends StatelessWidget {
  final double p;
  const _PulseDot({required this.p});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 16,
        height: 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 8 + 8 * p,
              height: 8 + 8 * p,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.red.withValues(alpha: .45 * (1 - p)),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: _C.red, shape: BoxShape.circle),
            ),
          ],
        ),
      );
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Pressable({required this.child, this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? .95 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
