import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'reset_password_screen.dart';
import 'terms_privacy_screen.dart';
import 'theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLogin = true;
  bool _hidePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.yellow,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _socialLogin(String provider) {
    _toast('Signing in with $provider...');
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            name: '$provider User',
            email: 'user@$provider.com'.toLowerCase(),
          ),
        ),
      );
    });
  }

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.yellow, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1E1E22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C2C32)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C2C32)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.yellow, width: 2),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF8A80), fontSize: 11.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    _isLogin ? 'Login' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? "We're so excited to see you again!"
                        : 'Sign up to get started with Sekure Delivery.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Form Card Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121216),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF222228)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              decoration: _inputDeco('Full Name', Icons.person_outline_rounded),
                              validator: (v) => (v == null || v.trim().length < 2) ? 'Enter full name' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                              decoration: _inputDeco('Phone Number', Icons.phone_outlined),
                              validator: (v) => (v == null || v.trim().length < 7) ? 'Enter phone number' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDeco('Email Address', Icons.email_outlined),
                            validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
                                ? null
                                : 'Enter a valid email address',
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            obscureText: _hidePassword,
                            decoration: _inputDeco(
                              'Password',
                              Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                          ),

                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              obscureText: _hidePassword,
                              decoration: _inputDeco('Confirm Password', Icons.lock_outline_rounded),
                              validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Remember me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.yellow,
                                      checkColor: Colors.black,
                                      side: const BorderSide(color: Colors.white54),
                                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Remember me', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                                ],
                              ),
                              if (_isLogin)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ResetPasswordScreen(isCourier: false),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.yellow,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Delivery Login Button with Animated Rider
                          DeliveryLoginButton(
                            label: _isLogin ? 'Login' : 'Register',
                            validate: () => _formKey.currentState?.validate() ?? false,
                            task: () async {
                              await Future.delayed(const Duration(milliseconds: 1400));
                            },
                            onSuccess: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => DashboardScreen(
                                    name: _isLogin ? _emailController.text.trim() : _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Social Sign-In Divider
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFF2C2C32))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFF2C2C32))),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Social Sign-In Buttons (Google, Apple, Facebook)
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Google',
                                  iconColor: AppColors.yellow,
                                  onTap: () => _socialLogin('Google'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.apple_rounded,
                                  label: 'Apple',
                                  iconColor: Colors.white,
                                  onTap: () => _socialLogin('Apple'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.facebook_rounded,
                                  label: 'Facebook',
                                  iconColor: const Color(0xFF1877F2),
                                  onTap: () => _socialLogin('Facebook'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Toggle Register / Login Footer
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: Text.rich(
                        TextSpan(
                          text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Register' : 'Login',
                              style: const TextStyle(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms & Privacy
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsPrivacyScreen(isCourierAgreement: false),
                          ),
                        );
                      },
                      child: const Text(
                        'Terms of Service  |  Privacy Policy',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C32)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.yellow.withValues(alpha: 0.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated login/register button.
class DeliveryLoginButton extends StatefulWidget {
  final String label;
  final bool Function() validate;
  final Future<void> Function() task;
  final VoidCallback onSuccess;
  final Color color;
  final Color ink;

  const DeliveryLoginButton({
    super.key,
    required this.label,
    required this.validate,
    required this.task,
    required this.onSuccess,
    this.color = AppColors.yellow,
    this.ink = Colors.black,
  });

  @override
  State<DeliveryLoginButton> createState() => _DeliveryLoginButtonState();
}

class _DeliveryLoginButtonState extends State<DeliveryLoginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  bool _running = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_running || !widget.validate()) return;
    setState(() => _running = true);
    try {
      await Future.wait([_c.forward(from: 0), widget.task()]);
      if (!mounted) return;
      widget.onSuccess();
    } catch (_) {
      if (!mounted) return;
      _c.reset();
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final idleOpacity = _running ? (1 - t / 0.06).clamp(0.0, 1.0) : 1.0;
          final sceneOpacity = !_running
              ? 0.0
              : (t < 0.04 ? t / 0.04 : (t > 0.90 ? (1 - (t - 0.90) / 0.05) : 1.0))
                  .clamp(0.0, 1.0);
          final doneOpacity = ((t - 0.93) / 0.07).clamp(0.0, 1.0);

          return Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: idleOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delivery_dining_rounded, color: widget.ink, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: sceneOpacity,
                  child: SizedBox.expand(
                    child: CustomPaint(painter: _ScenePainter(t, widget.ink, widget.color)),
                  ),
                ),
                Opacity(
                  opacity: doneOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: widget.ink, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Delivered!',
                        style: TextStyle(
                          color: widget.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final double t;
  final Color ink;
  final Color bg;
  _ScenePainter(this.t, this.ink, this.bg);

  static double _seg(double t, double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final gy = size.height - 6; // ground line
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = ink;

    // Road (dashed)
    final road = Paint()
      ..color = ink.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    for (double x = 6; x < w; x += 14) {
      canvas.drawLine(Offset(x, gy + 1), Offset(x + 7, gy + 1), road);
    }

    // Phases
    final ride = _seg(t, 0.0, 0.50, Curves.easeOutCubic);
    final toss = _seg(t, 0.50, 0.72);
    final wave = _seg(t, 0.72, 0.92);
    final riderX = -26 + (w * 0.50 + 26) * ride;
    final personX = w * 0.82;

    _drawPerson(canvas, Offset(personX, gy), stroke, fill, toss, wave);

    final bounce = math.sin(riderX / 6) * (ride < 1 ? 0.8 : 0.0);
    _drawRider(canvas, Offset(riderX, gy + bounce), stroke, fill, toss);

    final handPos = Offset(riderX + 17, gy - 22);
    final landPos = Offset(personX - 20, gy - 5.5);
    Offset pkg;
    if (t < 0.50) {
      pkg = handPos;
    } else {
      final x = handPos.dx + (landPos.dx - handPos.dx) * Curves.easeOut.transform(toss);
      final y = handPos.dy + (landPos.dy - handPos.dy) * Curves.bounceOut.transform(toss);
      pkg = Offset(x, y);
    }
    _drawPackage(canvas, pkg, 10);

    final pop = _seg(t, 0.72, 0.84, Curves.elasticOut);
    if (pop > 0) {
      final c = Offset(landPos.dx, gy - 24);
      canvas.drawCircle(c, 8 * pop, fill);
      final tick = Paint()
        ..color = bg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final p = Path()
        ..moveTo(c.dx - 3.5 * pop, c.dy)
        ..lineTo(c.dx - 1 * pop, c.dy + 3 * pop)
        ..lineTo(c.dx + 4 * pop, c.dy - 3 * pop);
      canvas.drawPath(p, tick);
    }
  }

  void _drawPackage(Canvas canvas, Offset c, double s) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: s, height: s),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF8D5B2E));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = ink,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - s / 2),
      Offset(c.dx, c.dy + s / 2),
      Paint()
        ..color = const Color(0xFFE9D3A8)
        ..strokeWidth = 1.6,
    );
  }

  void _drawRider(Canvas canvas, Offset g, Paint stroke, Paint fill, double toss) {
    final wy = g.dy - 6;
    final x = g.dx;
    final spin = x / 6;

    for (final wx in [x - 14, x + 14]) {
      canvas.drawCircle(Offset(wx, wy), 6, stroke);
      final sp = Paint()
        ..color = ink
        ..strokeWidth = 1.2;
      for (int i = 0; i < 3; i++) {
        final a = spin + i * math.pi / 3;
        canvas.drawLine(
          Offset(wx + math.cos(a) * 5, wy + math.sin(a) * 5),
          Offset(wx - math.cos(a) * 5, wy - math.sin(a) * 5),
          sp,
        );
      }
    }

    final frame = Path()
      ..moveTo(x - 14, wy)
      ..lineTo(x - 7, wy - 4)
      ..lineTo(x + 9, wy - 4)
      ..lineTo(x + 14, wy);
    canvas.drawPath(frame, stroke);
    canvas.drawLine(Offset(x + 10, wy - 4), Offset(x + 12, wy - 19), stroke);
    canvas.drawLine(Offset(x + 12, wy - 19), Offset(x + 8, wy - 20), stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 19, wy - 25, 12, 11),
        const Radius.circular(2),
      ),
      fill,
    );
    canvas.drawLine(
      Offset(x - 19, wy - 21),
      Offset(x - 7, wy - 21),
      Paint()
        ..color = bg
        ..strokeWidth = 1.2,
    );

    final lean = toss > 0 ? 1.5 : 0.0;
    final hip = Offset(x - 3, wy - 6);
    final shoulder = Offset(x - 2 + lean, wy - 19);
    canvas.drawLine(hip, shoulder, stroke..strokeWidth = 5);
    stroke.strokeWidth = 2.5;
    canvas.drawLine(hip, Offset(x + 7, wy - 4), stroke);

    final head = Offset(shoulder.dx + 1, shoulder.dy - 7);
    canvas.drawCircle(head, 4.5, fill);
    canvas.drawArc(
      Rect.fromCircle(center: head, radius: 5.5),
      math.pi,
      math.pi,
      false,
      stroke..strokeWidth = 2,
    );
    stroke.strokeWidth = 2.5;

    final bar = Offset(x + 9, wy - 19);
    final out = Offset(x + 18, wy - 22);
    final reach = toss > 0 ? Curves.easeOut.transform((toss * 3).clamp(0.0, 1.0)) : 0.0;
    final hand = Offset.lerp(bar, out, reach)!;
    canvas.drawLine(Offset(shoulder.dx, shoulder.dy + 1), hand, stroke);
  }

  void _drawPerson(Canvas canvas, Offset g, Paint stroke, Paint fill, double toss, double wave) {
    final x = g.dx;
    final hip = Offset(x, g.dy - 12);
    final shoulder = Offset(x, g.dy - 25);

    canvas.drawLine(hip, Offset(x - 3, g.dy), stroke);
    canvas.drawLine(hip, Offset(x + 3, g.dy), stroke);
    canvas.drawLine(hip, shoulder, stroke..strokeWidth = 5);
    stroke.strokeWidth = 2.5;
    canvas.drawCircle(Offset(x, shoulder.dy - 7), 4.5, fill);

    canvas.drawLine(shoulder, Offset(x + 5, g.dy - 14), stroke);
    final w = math.sin(wave * math.pi * 6) * 0.5;
    final handUp = Offset(x - 8 + w * 3, g.dy - 34 + math.cos(wave * math.pi * 6) * 1.5);
    final handDown = Offset(x - 5, g.dy - 14);
    final up = wave > 0 ? 1.0 : 0.0;
    canvas.drawLine(shoulder, Offset.lerp(handDown, handUp, up)!, stroke);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.t != t;
}
