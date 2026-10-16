import 'package:flutter/material.dart';
import 'theme.dart';

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

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCourierView = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isCourierView ? AppColors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: !_isCourierView ? AppColors.yellow : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Customer Health',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: !_isCourierView ? AppColors.yellow : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCourierView = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isCourierView ? AppColors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.two_wheeler_rounded,
                      size: 18,
                      color: _isCourierView ? AppColors.yellow : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Driver Health & Safety',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: _isCourierView ? AppColors.yellow : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHealthDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Health & Eco Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'CUSTOMER ECO-WELLNESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '🌱 Tier 1 Green Shipper',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_customerSteps Steps Walked',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Walked to local pickup hubs • $_customerCalories kcal burned',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Activity Stats Row
        Row(
          children: [
            Expanded(
              child: _HealthMetricTile(
                title: 'Carbon Saved',
                value: '${_carbonSavedKg}kg CO₂',
                subtitle: 'Green deliveries',
                icon: Icons.eco_rounded,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _HealthMetricTile(
                title: 'Calories Burned',
                value: '$_customerCalories kcal',
                subtitle: 'Walking pickups',
                icon: Icons.local_fire_department_rounded,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Customer Hydration Tracker
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.sky, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Hydration',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_customerWaterLiters.toStringAsFixed(1)}L / 2.0L goal',
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sky,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  setState(() {
                    if (_customerWaterLiters < 2.5) {
                      _customerWaterLiters += 0.25;
                    }
                  });
                  _toast('Logged +250ml Water intake!');
                },
                child: const Text('+250ml', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Unboxing Hygiene & Package Safety Guide
        const Text(
          'Package Ergonomics & Hygiene Guide',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            children: [
              _GuideRow(
                icon: Icons.sanitizer_rounded,
                title: 'Parcel Hygiene Care',
                description: 'Sanitize or wash hands thoroughly after unboxing cardboard & plastic delivery wrappers.',
              ),
              Divider(height: 20),
              _GuideRow(
                icon: Icons.fitness_center_rounded,
                title: 'Heavy Box Lifting',
                description: 'Bend at your knees and keep heavy parcel packages close to your chest to protect lumbar muscles.',
              ),
              Divider(height: 20),
              _GuideRow(
                icon: Icons.recycling_rounded,
                title: 'Eco Recycling',
                description: 'Recycle outer cardboard boxes at local green disposal centers.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourierHealthDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Fatigue & Shift Control
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isOnRestBreak
                          ? AppColors.sky.withValues(alpha: 0.2)
                          : AppColors.yellow.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isOnRestBreak ? Icons.coffee_rounded : Icons.timer_rounded,
                      color: _isOnRestBreak ? AppColors.sky : AppColors.yellow,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnRestBreak ? 'REST BREAK ACTIVE' : 'RIDING SHIFT TIME',
                          style: TextStyle(
                            color: _isOnRestBreak ? AppColors.sky : AppColors.yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isOnRestBreak
                              ? 'Orders paused. Rest for 15 minutes to recharge.'
                              : '$_ridingHours hrs $_ridingMins mins active today',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _isOnRestBreak ? 1.0 : 0.72,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: _isOnRestBreak ? AppColors.sky : AppColors.orange,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnRestBreak
                      ? const Color(0xFF10B981)
                      : AppColors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() => _isOnRestBreak = !_isOnRestBreak);
                  _toast(_isOnRestBreak
                      ? 'Rest break active! Take time to stretch & drink water.'
                      : 'Active riding shift resumed. Drive safely!');
                },
                icon: Icon(_isOnRestBreak ? Icons.play_arrow_rounded : Icons.pause_circle_filled_rounded),
                label: Text(
                  _isOnRestBreak ? 'RESUME DELIVERIES' : 'TAKE A 15-MIN REST BREAK',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Activity Stats Row (Steps, Calories)
        Row(
          children: [
            Expanded(
              child: _HealthMetricTile(
                title: 'Parcel Handling Steps',
                value: '$_driverSteps',
                subtitle: 'Goal: 10,000 steps',
                icon: Icons.directions_walk_rounded,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _HealthMetricTile(
                title: 'Active Calories',
                value: '$_driverCalories kcal',
                subtitle: 'Parcel loading burn',
                icon: Icons.local_fire_department_rounded,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Driver Hydration Control
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.sky, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shift Hydration Target',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_driverWaterLiters.toStringAsFixed(1)}L / 2.5L goal',
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sky,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  setState(() {
                    if (_driverWaterLiters < 2.8) {
                      _driverWaterLiters += 0.25;
                    }
                  });
                  _toast('Logged +250ml Water! Hydration on track.');
                },
                child: const Text('+250ml', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Heavy Package Lifting Posture Guide
        const Text(
          'Driver Posture & Heavy Parcel Ergonomics',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            children: [
              _GuideRow(
                icon: Icons.accessibility_new_rounded,
                title: 'Squat & Bend Knees',
                description: 'Squat down when lifting heavy boxes from ground level to avoid lower back strain.',
              ),
              Divider(height: 20),
              _GuideRow(
                icon: Icons.center_focus_strong_rounded,
                title: 'Keep Load Close to Spine',
                description: 'Hold heavy parcels close to your body chest to minimize spinal disc pressure by 60%.',
              ),
              Divider(height: 20),
              _GuideRow(
                icon: Icons.fitness_center_rounded,
                title: 'Max Weight Limit: 25 kg',
                description: 'Request a trolley or co-courier assistance for packages exceeding 25 kg.',
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'HEALTH DASHBOARD',
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.favorite_rounded, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 4),
                Text(
                  'Score 98/100',
                  style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildRoleToggle(),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isCourierView ? _buildCourierHealthDashboard() : _buildCustomerHealthDashboard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _HealthMetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.black),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
