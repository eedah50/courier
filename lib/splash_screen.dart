import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'terms_privacy_screen.dart';
import 'theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TermsPrivacyScreen(isFirstTimeOnboarding: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lemon,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          double seg(double a, double b) =>
              Interval(a, b, curve: Curves.easeOut).transform(t);

          return SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AspectRatio(
                      aspectRatio: 360 / 240,
                      child: CustomPaint(painter: _ScenePainter(t)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: seg(.5, .8),
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - seg(.5, .8))),
                      child: Column(
                        children: [
                          const Text(
                            'SEKURE',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const Text(
                            'DELIVERY',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 64,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.sky,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Delivered safe. Delivered fast.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: 190,
                    height: 6,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: t.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.orange, AppColors.sky],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Draws the whole delivery scene in a 360 x 240 coordinate space.
///
/// Timeline (t = 0..1):
///  0.00-0.50  bike rides in and brakes
///  0.46-0.62  door opens, person walks out to meet the courier
///  0.50-0.60  courier picks the parcel up and holds it out
///  0.66-0.76  parcel is handed from courier to person
///  0.76-0.95  confetti + "delivered" check badge
///  0.82-1.00  bike rides off (person stays, holding the parcel)
class _ScenePainter extends CustomPainter {
  _ScenePainter(this.t);
  final double t;

  static const double _w = 360, _h = 240, _road = 192, _stopX = 170;

  double _seg(double a, double b, [Curve c = Curves.linear]) =>
      Interval(a, b, curve: c).transform(t);

  /// Where the person's hand is, given their x position and grab progress.
  Offset _personHand(double x, double grab) =>
      Offset.lerp(Offset(x - 4, _road - 30), Offset(x - 18, _road - 44), grab)!;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _w);
    canvas.clipRect(const Rect.fromLTWH(0, 0, _w, _h));

    _cloud(canvas, 40 + t * 18, 48, 1);
    _cloud(canvas, 170 + t * 10, 82, .7);
    _house(canvas, t >= .46);
    _ground(canvas);

    // Bike position & speed
    final ride1 = _seg(0, .5, Curves.easeOutCubic);
    final ride2 = _seg(.82, 1, Curves.easeInCubic);
    final bx = -90 + (_stopX + 90) * ride1 + 270 * ride2;
    final p1 = _seg(0, .5);
    final p2 = _seg(.82, 1);
    final speed = math.max(
      t < .5 ? math.pow(1 - p1, 2).toDouble() : 0.0,
      t > .82 ? p2 * p2 : 0.0,
    );
    final bob = math.sin(t * 90) * 1.2 * speed;
    final by = _road - 18 + bob;

    // Speed lines
    if (speed > .05) {
      final sp = Paint()
        ..color = AppColors.black.withValues(alpha: speed * .5)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final y = by - 22 + i * 14;
        canvas.drawLine(
          Offset(bx - 38 - i * 10 - 34 * speed, y),
          Offset(bx - 34, y),
          sp,
        );
      }
    }

    // Courier stretches an arm out while handing over the parcel
    final reach =
        _seg(.5, .58, Curves.easeOut) * (1 - _seg(.74, .82, Curves.easeIn));
    _bike(canvas, bx, by, reach);

    // Person comes out of the door to meet the courier
    final walk = _seg(.46, .62, Curves.easeInOut);
    final personX = 300 - 34 * walk;
    final grab = _seg(.62, .7, Curves.easeOut);
    if (t >= .46) _person(canvas, personX, walk, grab);

    // Parcel: on the rack -> in courier's hand -> in person's hand
    final courierHand = Offset(
      bx + 53 + 19 * reach,
      by - 44 + 4 * reach,
    );
    final heldByCourier = courierHand + const Offset(8, -4);
    final heldByPerson = _personHand(personX, grab) + const Offset(-8, -4);
    final rack = Offset(bx - 12, by - 36);

    Offset pos;
    var ang = 0.0;
    if (t < .5) {
      pos = rack;
    } else if (t < .6) {
      final p = _seg(.5, .6, Curves.easeInOut);
      pos = Offset.lerp(rack, heldByCourier, p)!;
      pos = pos.translate(0, -26 * math.sin(p * math.pi));
      ang = -.4 * math.sin(p * math.pi);
    } else if (t < .66) {
      pos = heldByCourier;
    } else if (t < .76) {
      final p = _seg(.66, .76, Curves.easeInOut);
      pos = Offset.lerp(heldByCourier, heldByPerson, p)!;
    } else {
      pos = heldByPerson;
    }
    _parcel(canvas, pos, ang);

    // Confetti
    final q = _seg(.76, .95, Curves.easeOut);
    if (t > .76 && q < 1) {
      const colors = [
        AppColors.black,
        AppColors.orange,
        AppColors.sky,
        Colors.white,
      ];
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final d = 10 + 40 * q;
        canvas.drawCircle(
          Offset(personX + math.cos(a) * d, 130 + math.sin(a) * d),
          3.5 * (1 - q),
          Paint()..color = colors[i % 4],
        );
      }
    }

    // Delivered badge
    final s = _seg(.78, .92, Curves.elasticOut);
    if (s > 0) {
      canvas.save();
      canvas.translate(300, 58);
      canvas.scale(s);
      canvas.drawCircle(Offset.zero, 20, Paint()..color = AppColors.orange);
      canvas.drawCircle(
        Offset.zero,
        20,
        Paint()
          ..color = AppColors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final check = Path()
        ..moveTo(-8, 0)
        ..lineTo(-2, 7)
        ..lineTo(9, -6);
      canvas.drawPath(
        check,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  void _cloud(Canvas c, double x, double y, double s) {
    final p = Paint()..color = Colors.white.withValues(alpha: .85);
    c.save();
    c.translate(x, y);
    c.scale(s);
    c.drawCircle(Offset.zero, 12, p);
    c.drawCircle(const Offset(16, -6), 16, p);
    c.drawCircle(const Offset(34, 0), 12, p);
    c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-10, 0, 54, 12), const Radius.circular(6)),
      p,
    );
    c.restore();
  }

  Paint _stroke(Color color, double w) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _house(Canvas c, bool doorOpen) {
    const body = Rect.fromLTWH(255, 130, 90, 62);
    c.drawRect(body, Paint()..color = Colors.white);
    c.drawRect(body, _stroke(AppColors.black, 3));

    final roof = Path()
      ..moveTo(247, 132)
      ..lineTo(300, 92)
      ..lineTo(353, 132)
      ..close();
    c.drawPath(roof, Paint()..color = AppColors.orange);
    c.drawPath(roof, _stroke(AppColors.black, 3));

    // Windows
    for (final r in const [
      Rect.fromLTWH(262, 142, 16, 16),
      Rect.fromLTWH(322, 142, 16, 16),
    ]) {
      c.drawRect(r, Paint()..color = AppColors.sky);
      c.drawRect(r, _stroke(AppColors.black, 2.5));
    }

    // Door (dark opening when someone is coming out)
    const door = Rect.fromLTWH(288, 150, 24, 42);
    c.drawRect(
      door,
      Paint()..color = doorOpen ? AppColors.black : AppColors.sky,
    );
    c.drawRect(door, _stroke(AppColors.black, 2.5));
    if (!doorOpen) {
      c.drawCircle(const Offset(306, 172), 2, Paint()..color = AppColors.black);
    }
  }

  void _ground(Canvas c) {
    c.drawRect(const Rect.fromLTWH(0, _road, _w, 14),
        Paint()..color = AppColors.black);
    final dash = Paint()..color = Colors.white.withValues(alpha: .8);
    for (double x = 10; x < _w; x += 48) {
      c.drawRect(Rect.fromLTWH(x, 198, 26, 3), dash);
    }
  }

  void _wheel(Canvas c, Offset o, double a) {
    c.drawCircle(o, 18, Paint()..color = Colors.white);
    c.drawCircle(o, 18, _stroke(AppColors.black, 4));
    final spoke = _stroke(Colors.black54, 1.5);
    for (var i = 0; i < 4; i++) {
      final d = Offset(
          math.cos(a + i * math.pi / 4), math.sin(a + i * math.pi / 4)) *
          16;
      c.drawLine(o - d, o + d, spoke);
    }
    c.drawCircle(o, 3, Paint()..color = AppColors.orange);
  }

  void _person(Canvas c, double x, double walk, double grab) {
    const g = _road;
    final swing =
    (walk > 0 && walk < 1) ? math.sin(walk * math.pi * 6) * 5 : 0.0;
    final skin = Paint()..color = const Color(0xFFE8B98A);

    // Legs
    c.drawLine(Offset(x, g - 26), Offset(x - 3 + swing, g),
        _stroke(AppColors.black, 6));
    c.drawLine(Offset(x, g - 26), Offset(x + 3 - swing, g),
        _stroke(AppColors.black, 6));

    // Torso
    c.drawLine(
        Offset(x, g - 26), Offset(x, g - 50), _stroke(AppColors.sky, 14));

    // Arm reaching for the parcel
    final shoulder = Offset(x, g - 48);
    final hand = _personHand(x, grab);
    c.drawLine(shoulder, hand, _stroke(AppColors.sky, 6));
    c.drawCircle(hand, 3.5, skin);

    // Head + hair
    final head = Offset(x, g - 60);
    c.drawCircle(head, 9, skin);
    c.drawArc(Rect.fromCircle(center: head, radius: 9), math.pi, math.pi, true,
        Paint()..color = AppColors.black);
  }

  void _bike(Canvas c, double bx, double by, double reach) {
    c.save();
    c.translate(bx, by);

    final wa = bx / 18;
    _wheel(c, Offset.zero, wa);
    _wheel(c, const Offset(58, 0), wa);

    const r = Offset.zero, bb = Offset(26, 0);
    const s = Offset(16, -32), h = Offset(50, -32), f = Offset(58, 0);

    // Pedals / crank
    final th = bx / 9;
    final arm = Offset(math.cos(th), math.sin(th)) * 9;
    final pedal = bb + arm;
    c.drawLine(bb, bb - arm, _stroke(AppColors.black, 3));
    c.drawLine(bb, pedal, _stroke(AppColors.black, 3));

    // Frame
    final frame = Path()
      ..moveTo(r.dx, r.dy)
      ..lineTo(s.dx, s.dy)
      ..lineTo(bb.dx, bb.dy)
      ..lineTo(r.dx, r.dy)
      ..moveTo(s.dx, s.dy)
      ..lineTo(h.dx, h.dy)
      ..lineTo(bb.dx, bb.dy)
      ..moveTo(h.dx, h.dy)
      ..lineTo(f.dx, f.dy);
    c.drawPath(frame, _stroke(AppColors.black, 4));

    // Handlebar, seat, rack
    c.drawLine(h, const Offset(52, -44), _stroke(AppColors.black, 4));
    c.drawLine(const Offset(52, -44), const Offset(62, -44),
        _stroke(AppColors.black, 5));
    c.drawLine(const Offset(8, -35), const Offset(24, -35),
        _stroke(AppColors.black, 6));
    c.drawLine(const Offset(-30, -22), const Offset(10, -22),
        _stroke(AppColors.black, 3));
    c.drawLine(const Offset(0, -2), const Offset(-14, -22),
        _stroke(AppColors.black, 3));

    // Rider: leg
    const hip = Offset(16, -36);
    final knee = (hip + pedal) / 2 + const Offset(9, -3);
    final leg = Path()
      ..moveTo(hip.dx, hip.dy)
      ..lineTo(knee.dx, knee.dy)
      ..lineTo(pedal.dx, pedal.dy);
    c.drawPath(leg, _stroke(AppColors.sky, 8));
    c.drawCircle(pedal, 3.5, Paint()..color = AppColors.black);

    // Torso, arm (hand stretches out when handing over the parcel)
    const shoulder = Offset(34, -66);
    final hand = Offset.lerp(
        const Offset(53, -44), const Offset(72, -40), reach)!;
    c.drawLine(hip, shoulder, _stroke(AppColors.orange, 13));
    final elbow = (shoulder + hand) / 2 + const Offset(0, 5);
    final armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(hand.dx, hand.dy);
    c.drawPath(armPath, _stroke(AppColors.orange, 6));
    c.drawCircle(hand, 3.5, Paint()..color = AppColors.black);

    // Helmet + visor
    c.drawCircle(const Offset(40, -80), 11, Paint()..color = AppColors.black);
    c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(41, -84, 11, 6), const Radius.circular(3)),
      Paint()..color = AppColors.sky,
    );

    c.restore();
  }

  void _parcel(Canvas c, Offset center, double angle) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    final box = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-16, -14, 32, 28), const Radius.circular(3));
    c.drawRRect(box, Paint()..color = AppColors.orange);
    c.drawRect(
        const Rect.fromLTWH(-3, -14, 6, 28), Paint()..color = Colors.white);
    c.drawRect(
        const Rect.fromLTWH(5, 3, 9, 7), Paint()..color = Colors.white);
    c.drawRRect(box, _stroke(AppColors.black, 3));
    c.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t;
}