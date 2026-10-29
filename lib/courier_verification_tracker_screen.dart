import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'courier_dashboard_screen.dart';
import 'theme.dart';

class CourierVerificationTrackerScreen extends StatefulWidget {
  final String driverName;
  final String email;

  const CourierVerificationTrackerScreen({
    super.key,
    required this.driverName,
    required this.email,
  });

  @override
  State<CourierVerificationTrackerScreen> createState() => _CourierVerificationTrackerScreenState();
}

class _CourierVerificationTrackerScreenState extends State<CourierVerificationTrackerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  bool _isApproved = false;

  @override
  void dispose() {
    _glowController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141002),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Verification & Inspection Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background mesh
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _GlassMeshBackgroundPainter(_glowController.value),
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lemon.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.lemon.withValues(alpha: 0.35),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.lemon.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_user_rounded, color: AppColors.lemon, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.driverName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.email,
                                        style: const TextStyle(color: Colors.white60, fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isApproved ? const Color(0xFF10B981) : AppColors.lemon,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _isApproved ? 'APPROVED' : 'IN REVIEW',
                                    style: const TextStyle(
                                      color: AppColors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'Document Submission Portal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Individual Driver & Fleet-Managed Rider Verification',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),

                            const SizedBox(height: 18),

                            _buildTrackerItem(
                              title: 'Profile Photo',
                              subtitle: 'Clear headshot submitted',
                              status: 'Verified',
                              isDone: true,
                            ),
                            _buildTrackerItem(
                              title: 'National Identification (NIN)',
                              subtitle: 'National ID card verified via NIMC',
                              status: 'Verified',
                              isDone: true,
                            ),
                            _buildTrackerItem(
                              title: 'Driver\'s License',
                              subtitle: 'Class-A/B commercial rider permit',
                              status: _isApproved ? 'Verified' : 'Under Review',
                              isDone: _isApproved,
                            ),
                            _buildTrackerItem(
                              title: 'Vehicle Registration & Insurance',
                              subtitle: 'Third-party commercial insurance',
                              status: _isApproved ? 'Verified' : 'Pending Inspection',
                              isDone: _isApproved,
                            ),
                            _buildTrackerItem(
                              title: 'Roadworthiness Certificate',
                              subtitle: 'Vehicle inspection station test passed',
                              status: _isApproved ? 'Verified' : 'Scheduled',
                              isDone: _isApproved,
                            ),

                            const SizedBox(height: 24),

                            // Action button
                            GestureDetector(
                              onTap: () {
                                if (!_isApproved) {
                                  setState(() => _isApproved = true);
                                  _toast('Admin simulation: Courier application approved successfully!');
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => CourierDashboardScreen(
                                        driverName: widget.driverName,
                                        email: widget.email,
                                        isVerified: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 52,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.lemon, AppColors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withValues(alpha: 0.4),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _isApproved ? 'Proceed to Courier Dashboard' : 'Simulate Admin Approval',
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerItem({
    required String title,
    required String subtitle,
    required String status,
    required bool isDone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isDone ? const Color(0xFF10B981) : AppColors.lemon,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF10B981).withValues(alpha: 0.2) : AppColors.lemon.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isDone ? const Color(0xFF10B981) : AppColors.lemon,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassMeshBackgroundPainter extends CustomPainter {
  final double progress;

  _GlassMeshBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final floatShift = math.sin(progress * math.pi * 2) * 20;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF141002));

    final yellowOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.lemon.withValues(alpha: 0.60),
          AppColors.yellow.withValues(alpha: 0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(w * 0.3 + floatShift, h * 0.22),
        radius: 280,
      ));

    final orangeOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.orange.withValues(alpha: 0.50),
          const Color(0xFFFF5722).withValues(alpha: 0.20),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(w * 0.85 - floatShift, h * 0.78),
        radius: 300,
      ));

    canvas.drawCircle(Offset(w * 0.3 + floatShift, h * 0.22), 280, yellowOrb);
    canvas.drawCircle(Offset(w * 0.85 - floatShift, h * 0.78), 300, orangeOrb);
  }

  @override
  bool shouldRepaint(_GlassMeshBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
