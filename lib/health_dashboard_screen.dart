import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'theme.dart';

const Color _kBg = Color(0xFFF6F5EF);

class HealthDashboardScreen extends StatefulWidget {
  final bool isCourierMode;
  final String userName;

  const HealthDashboardScreen({
    super.key,
    this.isCourierMode = false,
    this.userName = 'Courier Partner',
  });

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  late bool _isCourierView;

  // Courier Driver Health State
  bool _isOnRestBreak = false;
  double _driverWaterLiters = 1.8;
  final int _driverSteps = 8650;
  final int _driverCalories = 520;
  final int _ridingHours = 4;
  final int _ridingMins = 20;

  static const int _breakSeconds = 15 * 60;
  int _breakSecondsLeft = _breakSeconds;
  Timer? _breakTimer;

  // Customer Health & Eco State
  final int _customerSteps = 3420;
  final int _customerCalories = 160;
  final double _carbonSavedKg = 4.2;
  double _customerWaterLiters = 1.5;

  @override
  void initState() {
    super.initState();
    _isCourierView = widget.isCourierMode;
  }

  @override
  void dispose() {
    _breakTimer?.cancel();
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

  String _n(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  String get _breakClock {
    final m = _breakSecondsLeft ~/ 60;
    final s = (_breakSecondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleBreak() {
    setState(() => _isOnRestBreak = !_isOnRestBreak);

    _breakTimer?.cancel();
    if (_isOnRestBreak) {
      _breakSecondsLeft = _breakSeconds;
      _breakTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_breakSecondsLeft > 1) {
          setState(() => _breakSecondsLeft--);
        } else {
          setState(() => _breakSecondsLeft = 0);
          t.cancel();
          _toast('Break complete. Resume deliveries when you are ready.');
        }
      });
    }

    _toast(_isOnRestBreak
        ? 'Rest break active! Take time to stretch & drink water.'
        : 'Active riding shift resumed. Drive safely!');
  }

  void _changeWater({required bool courier, required double delta}) {
    setState(() {
      if (courier) {
        _driverWaterLiters = (_driverWaterLiters + delta).clamp(0.0, 3.0);
      } else {
        _customerWaterLiters = (_customerWaterLiters + delta).clamp(0.0, 2.5);
      }
    });
    if (delta > 0) {
      _toast(courier
          ? 'Logged +250ml Water! Hydration on track.'
          : 'Logged +250ml Water intake!');
    }
  }

  // ---------------------------------------------------------------------------
  // Header
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
                      const Spacer(),
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
                            const Icon(Icons.person_rounded,
                                color: AppColors.lemon, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.health_and_safety_rounded,
                                    color: AppColors.lemon, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'HEALTH DASHBOARD',
                                  style: TextStyle(
                                    color: AppColors.lemon,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your Wellness',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _isCourierView
                                    ? 'Stay safe and sharp on every delivery.'
                                    : 'Small habits, healthier deliveries.',
                                key: ValueKey(_isCourierView),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Score gauge
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 0.98),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(78, 78),
                                painter: _RingPainter(
                                  value: v,
                                  stroke: 7,
                                  track: Colors.white.withValues(alpha: 0.12),
                                  color: AppColors.lemon,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(v * 100).round()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'SCORE',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Role toggle (sliding thumb)
  // ---------------------------------------------------------------------------
  Widget _buildRoleToggle() {
    Widget item(String label, IconData icon, bool courier) {
      final selected = _isCourierView == courier;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isCourierView = courier),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey(selected),
                    size: 18,
                    color: selected ? AppColors.lemon : Colors.black45,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: selected ? AppColors.lemon : Colors.black54,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
            _isCourierView ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          Row(
            children: [
              item('Customer Health', Icons.person_rounded, false),
              item('Driver Safety', Icons.two_wheeler_rounded, true),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Customer view
  // ---------------------------------------------------------------------------
  Widget _buildCustomerHealthDashboard() {
    return Column(
      key: const ValueKey('customer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FadeSlide(
          index: 0,
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  bottom: -70,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.lemon.withValues(alpha: 0.28),
                          AppColors.lemon.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded,
                            color: AppColors.lemon, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'CUSTOMER ECO-WELLNESS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lemon.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: AppColors.lemon.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              color: AppColors.lemon, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'Tier 1 Green Shipper',
                            style: TextStyle(
                              color: AppColors.lemon,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _n(_customerSteps),
                                style: const TextStyle(
                                  color: AppColors.lemon,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: -1,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'steps walked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Walked to local pickup hubs • $_customerCalories kcal burned',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16)),
                          ),
                          child: const Icon(
                            Icons.directions_walk_rounded,
                            color: AppColors.lemon,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _FadeSlide(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.eco_rounded,
                  value: '${_carbonSavedKg.toStringAsFixed(1)} kg',
                  title: 'CO₂ Saved',
                  subtitle: 'Green deliveries',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MetricTile(
                  icon: Icons.local_fire_department_rounded,
                  value: '$_customerCalories kcal',
                  title: 'Calories Burned',
                  subtitle: 'Walking pickups',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _FadeSlide(
          index: 2,
          child: _HydrationCard(
            title: 'Daily Hydration',
            liters: _customerWaterLiters,
            goal: 2.0,
            max: 2.5,
            onChange: (d) => _changeWater(courier: false, delta: d),
          ),
        ),

        const SizedBox(height: 26),

        _FadeSlide(
          index: 3,
          child: const _GuideCard(
            title: 'Package Ergonomics & Hygiene',
            rows: [
              _GuideRow(
                icon: Icons.sanitizer_rounded,
                title: 'Parcel Hygiene Care',
                description:
                'Sanitize or wash hands thoroughly after unboxing cardboard & plastic delivery wrappers.',
              ),
              _GuideRow(
                icon: Icons.fitness_center_rounded,
                title: 'Heavy Box Lifting',
                description:
                'Bend at your knees and keep heavy parcel packages close to your chest to protect lumbar muscles.',
              ),
              _GuideRow(
                icon: Icons.recycling_rounded,
                title: 'Eco Recycling',
                description:
                'Recycle outer cardboard boxes at local green disposal centers.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Courier view
  // ---------------------------------------------------------------------------
  Widget _buildShiftCard() {
    final onBreak = _isOnRestBreak;
    final ringValue = onBreak ? _breakSecondsLeft / _breakSeconds : 0.72;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lemon.withValues(alpha: 0.26),
                    AppColors.lemon.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  // Ring
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: ringValue),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(112, 112),
                            painter: _RingPainter(
                              value: v,
                              stroke: 9,
                              track: Colors.white.withValues(alpha: 0.12),
                              color: AppColors.lemon,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                onBreak
                                    ? _breakClock
                                    : '${_ridingHours}h ${_ridingMins}m',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                onBreak ? 'BREAK LEFT' : 'ACTIVE TODAY',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.lemon.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: AppColors.lemon.withValues(alpha: 0.45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                onBreak
                                    ? Icons.coffee_rounded
                                    : Icons.timer_rounded,
                                color: AppColors.lemon,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                onBreak ? 'REST BREAK' : 'ON SHIFT',
                                style: const TextStyle(
                                  color: AppColors.lemon,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          onBreak
                              ? 'Orders paused. Rest for 15 minutes to recharge.'
                              : '$_ridingHours hrs $_ridingMins mins active today',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lemon,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _toggleBreak,
                  icon: Icon(
                    onBreak
                        ? Icons.play_arrow_rounded
                        : Icons.pause_circle_filled_rounded,
                  ),
                  label: Text(
                    onBreak ? 'RESUME DELIVERIES' : 'TAKE A 15-MIN REST BREAK',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourierHealthDashboard() {
    return Column(
      key: const ValueKey('courier'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FadeSlide(index: 0, child: _buildShiftCard()),

        const SizedBox(height: 16),

        _FadeSlide(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.directions_walk_rounded,
                  value: _n(_driverSteps),
                  title: 'Parcel Handling Steps',
                  subtitle: 'Goal: 10,000 steps',
                  progress: _driverSteps / 10000,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MetricTile(
                  icon: Icons.local_fire_department_rounded,
                  value: '$_driverCalories kcal',
                  title: 'Active Calories',
                  subtitle: 'Parcel loading burn',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _FadeSlide(
          index: 2,
          child: _HydrationCard(
            title: 'Shift Hydration Target',
            liters: _driverWaterLiters,
            goal: 2.5,
            max: 3.0,
            onChange: (d) => _changeWater(courier: true, delta: d),
          ),
        ),

        const SizedBox(height: 26),

        _FadeSlide(
          index: 3,
          child: const _GuideCard(
            title: 'Driver Posture & Parcel Ergonomics',
            rows: [
              _GuideRow(
                icon: Icons.accessibility_new_rounded,
                title: 'Squat & Bend Knees',
                description:
                'Squat down when lifting heavy boxes from ground level to avoid lower back strain.',
              ),
              _GuideRow(
                icon: Icons.center_focus_strong_rounded,
                title: 'Keep Load Close to Spine',
                description:
                'Hold heavy parcels close to your chest to reduce pressure on your spinal discs.',
              ),
              _GuideRow(
                icon: Icons.fitness_center_rounded,
                title: 'Max Weight Limit: 25 kg',
                description:
                'Request a trolley or co-courier assistance for packages exceeding 25 kg.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _buildRoleToggle(),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isCourierView
                      ? _buildCourierHealthDashboard()
                      : _buildCustomerHealthDashboard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Staggered entrance
// -----------------------------------------------------------------------------
class _FadeSlide extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeSlide({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// Metric tile
// -----------------------------------------------------------------------------
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final String subtitle;
  final double? progress;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lemon,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.black, size: 22),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress!.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Hydration tracker with segmented bar (250ml per segment)
// -----------------------------------------------------------------------------
class _HydrationCard extends StatelessWidget {
  final String title;
  final double liters;
  final double goal;
  final double max;
  final void Function(double delta) onChange;

  const _HydrationCard({
    required this.title,
    required this.liters,
    required this.goal,
    required this.max,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final segments = (goal / 0.25).round();
    final filled = (liters / 0.25).floor();
    final percent = ((liters / goal) * 100).round().clamp(0, 100);
    final reached = liters >= goal;
    final atMax = liters >= max;
    final atZero = liters <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    color: AppColors.lemon, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${liters.toStringAsFixed(1)}L / ${goal.toStringAsFixed(1)}L goal',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: reached ? AppColors.lemon : const Color(0xFFF6F5EF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reached) ...[
                      const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.black),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Segmented bar
          Row(
            children: [
              for (var i = 0; i < segments; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250 + i * 25),
                    curve: Curves.easeOut,
                    height: 12,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? AppColors.lemon
                          : Colors.black.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                      border: i < filled
                          ? Border.all(
                          color: AppColors.black.withValues(alpha: 0.12))
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              // Undo
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                  onPressed: atZero ? null : () => onChange(-0.25),
                  child: const Icon(Icons.remove_rounded,
                      color: AppColors.black, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.lemon,
                      disabledBackgroundColor: Colors.black12,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: atMax ? null : () => onChange(0.25),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      '+250ml',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Guide card
// -----------------------------------------------------------------------------
class _GuideCard extends StatelessWidget {
  final String title;
  final List<_GuideRow> rows;

  const _GuideCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.black45,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: rows[i],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuideRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lemon.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.black, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Progress ring
// -----------------------------------------------------------------------------
class _RingPainter extends CustomPainter {
  final double value; // 0..1
  final double stroke;
  final Color track;
  final Color color;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
          old.stroke != stroke ||
          old.track != track ||
          old.color != color;
}