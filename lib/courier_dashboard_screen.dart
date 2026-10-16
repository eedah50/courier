import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'ai_assistant_screen.dart';
import 'chat_screen.dart';
import 'event_reminder_screen.dart';
import 'health_dashboard_screen.dart';
import 'role_selection_screen.dart';
import 'support_chat_screen.dart';
import 'theme.dart';

class CourierDashboardScreen extends StatefulWidget {
  final String driverName;
  final String email;
  final bool isVerified;

  const CourierDashboardScreen({
    super.key,
    required this.driverName,
    required this.email,
    this.isVerified = false,
  });

  @override
  State<CourierDashboardScreen> createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  bool _isOnline = true;
  int _selectedTab = 0;

  // Driver Health, Ergonomics & Safety State
  double _waterIntakeLiters = 1.8;
  final int _driverSteps = 8650;
  bool _isOnRestBreak = false;

  // Driver Wallet State
  double _walletBalance = 48500.0;
  final double _pendingPayout = 14200.0;
  final List<Map<String, dynamic>> _walletTransactions = [
    {'title': 'Trip Payout #SKR-8842', 'subtitle': 'Today, 11:30 AM', 'amount': 4500.0, 'isCredit': true},
    {'title': 'Weekly Performance Bonus', 'subtitle': 'Yesterday, 9:00 PM', 'amount': 5000.0, 'isCredit': true},
    {'title': 'Trip Payout #SKR-8839', 'subtitle': 'Yesterday, 4:15 PM', 'amount': 3800.0, 'isCredit': true},
    {'title': 'Bank Withdrawal (First Bank)', 'subtitle': '16 Jan, 10:00 AM', 'amount': -30000.0, 'isCredit': false},
  ];

  final List<Map<String, dynamic>> _availableOrders = [
    {
      'id': 'SKR-8842',
      'pickup': '12 Ikeja City Mall, Lagos',
      'dropoff': '45 Victoria Island, Lagos',
      'distance': '6.4 km',
      'payout': '₦4,500',
      'package': 'Electronics Box (2.5 kg)',
      'urgent': true,
    },
    {
      'id': 'SKR-8845',
      'pickup': '8 Allen Avenue, Ikeja',
      'dropoff': '18 Maryland Estate, Lagos',
      'distance': '3.2 km',
      'payout': '₦2,800',
      'package': 'Legal Documents (0.4 kg)',
      'urgent': false,
    },
    {
      'id': 'SKR-8849',
      'pickup': 'Lekki Phase 1, Gate 2',
      'dropoff': 'Chevron Drive, Lekki',
      'distance': '8.1 km',
      'payout': '₦5,200',
      'package': 'Gift Hamper (4.1 kg)',
      'urgent': true,
    },
  ];

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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gorgeous Online / Offline Toggle Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.black, Color(0xFF1E1E2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isOnline
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isOnline ? Icons.radar_rounded : Icons.power_settings_new_rounded,
                    color: _isOnline ? const Color(0xFF10B981) : Colors.white54,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isOnline ? const Color(0xFF10B981) : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isOnline ? 'RIDER ONLINE & RADAR ACTIVE' : 'RIDER OFFLINE',
                            style: TextStyle(
                              color: _isOnline ? const Color(0xFF10B981) : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isOnline ? 'Scanning for high-payout orders nearby' : 'Go online to receive trip requests',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isOnline,
                  activeColor: AppColors.yellow,
                  activeTrackColor: AppColors.orange,
                  onChanged: (val) {
                    setState(() => _isOnline = val);
                    _toast(val ? 'Radar activated: You are online' : 'You are now offline');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Verification Status Banner
          if (!widget.isVerified)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Under Review',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your documents are queued for verification. You can still browse orders.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Driver Stats Bento Grid
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  title: "Today's Payout",
                  value: '₦18,500',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  title: 'Trips Done',
                  value: '14',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.sky,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  title: 'Driver Rating',
                  value: '4.9 ★',
                  icon: Icons.star_rounded,
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Available Orders Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Delivery Requests',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_availableOrders.length} Nearby',
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (!_isOnline)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.radar_outlined,
                    size: 54,
                    color: Colors.black38,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Radar is Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Switch on your online status above to start accepting delivery orders.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _availableOrders[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: item['urgent'] == true
                          ? AppColors.orange.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.06),
                      width: item['urgent'] == true ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['id'],
                                  style: const TextStyle(
                                    color: AppColors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (item['urgent'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    '⚡ EXPRESS',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            item['payout'],
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.circle,
                                  size: 10, color: AppColors.sky),
                              Container(
                                width: 2,
                                height: 28,
                                color: Colors.black26,
                              ),
                              const Icon(Icons.location_on_rounded,
                                  size: 16, color: AppColors.orange),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['pickup'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  item['dropoff'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['package'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.alt_route_rounded,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['distance'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.orange),
                                tooltip: 'Chat with Customer',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        orderId: item['id'],
                                        peerName: 'Amara Okafor',
                                        peerRole: 'Customer',
                                        peerPhone: '+234 802 111 2233',
                                        vehicleInfo: 'Waybill Recipient',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.black,
                                  foregroundColor: AppColors.yellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  _toast(
                                      'Delivery ${item['id']} accepted! Route starting...');
                                },
                                child: const Text(
                                  'ACCEPT',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Documents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Status of documents uploaded during driver onboarding.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _DocStatusTile(
            title: 'Government-Issued Photo ID',
            subtitle: 'National Identity Card (NIN)',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.badge_rounded,
          ),
          _DocStatusTile(
            title: 'Live Selfie / Liveness Check',
            subtitle: 'Biometric photo match completed',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.face_retouching_natural_rounded,
          ),
          _DocStatusTile(
            title: 'Proof of Residential Address',
            subtitle: 'Utility Bill (Electricity/Water)',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.home_work_rounded,
          ),
          _DocStatusTile(
            title: 'Driver’s License & Inspection',
            subtitle: 'Class B License • Plate: LA-492-IKJ',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.drive_eta_rounded,
          ),
          _DocStatusTile(
            title: 'Police Clearance Certificate',
            subtitle: 'Clear Criminal Record Check',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.verified_user_rounded,
          ),
          _DocStatusTile(
            title: 'Guarantor / Next of Kin Information',
            subtitle: 'Guarantor details confirmed',
            status: widget.isVerified ? 'Verified' : 'Under Review',
            isVerified: widget.isVerified,
            icon: Icons.people_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver Health & Safety',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Fatigue management, posture care & physical wellness.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HealthDashboardScreen(
                        isCourierMode: true,
                        userName: widget.driverName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Full Dashboard',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Shift Fatigue & Rest Break Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                        _isOnRestBreak
                            ? Icons.coffee_rounded
                            : Icons.timer_rounded,
                        color: _isOnRestBreak ? AppColors.sky : AppColors.yellow,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnRestBreak ? 'REST BREAK ACTIVE' : 'ACTIVE SHIFT TIME',
                            style: TextStyle(
                              color: _isOnRestBreak ? AppColors.sky : AppColors.yellow,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isOnRestBreak
                                ? 'Orders paused. Rest for 15 mins to recharge.'
                                : '4 hours 20 minutes riding today',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _isOnRestBreak ? 1.0 : 0.72,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    color: _isOnRestBreak ? AppColors.sky : AppColors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOnRestBreak
                        ? const Color(0xFF10B981)
                        : AppColors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isOnRestBreak = !_isOnRestBreak);
                    _toast(_isOnRestBreak
                        ? 'Rest break activated! Take time to stretch & hydrate.'
                        : 'Welcome back! You are now active for deliveries.');
                  },
                  icon: Icon(_isOnRestBreak
                      ? Icons.play_arrow_rounded
                      : Icons.pause_circle_filled_rounded),
                  label: Text(
                    _isOnRestBreak ? 'RESUME DELIVERIES' : 'TAKE A 15-MIN REST BREAK',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Daily Activity Metrics Row (Steps, Calories)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.directions_walk_rounded, color: AppColors.orange, size: 24),
                      const SizedBox(height: 10),
                      Text(
                        '$_driverSteps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                      const Text('Steps Walked', style: TextStyle(color: Colors.black54, fontSize: 11)),
                      const SizedBox(height: 6),
                      const Text('Goal: 10,000 steps', style: TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 24),
                      const SizedBox(height: 10),
                      const Text(
                        '520 kcal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                      const Text('Active Calories', style: TextStyle(color: Colors.black54, fontSize: 11)),
                      const SizedBox(height: 6),
                      const Text('Parcel Handling', style: TextStyle(color: Colors.deepOrange, fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Water Intake Tracker
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sky.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: AppColors.sky, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shift Hydration',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_waterIntakeLiters.toStringAsFixed(1)}L / 2.5L daily goal',
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sky,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_waterIntakeLiters < 2.5) {
                        _waterIntakeLiters += 0.25;
                      }
                    });
                    _toast('Logged +250ml Water! Stay hydrated.');
                  },
                  child: const Text('+250ml', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Heavy Package Lifting & Posture Ergonomics Guide
          const Text(
            'Ergonomics & Heavy Lifting Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: const Column(
              children: [
                _ErgonomicGuideTile(
                  icon: Icons.accessibility_new_rounded,
                  title: 'Bend Knees, Not Back',
                  subtitle: 'Squat down when lifting heavy boxes from the ground.',
                ),
                Divider(height: 16),
                _ErgonomicGuideTile(
                  icon: Icons.center_focus_strong_rounded,
                  title: 'Keep Load Close to Chest',
                  subtitle: 'Reduces strain on your lower lumbar spine by up to 60%.',
                ),
                Divider(height: 16),
                _ErgonomicGuideTile(
                  icon: Icons.fitness_center_rounded,
                  title: 'Max Weight Limit: 25 kg',
                  subtitle: 'Use a delivery trolley or request help for heavier packages.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.black, Color(0xFF1E1E2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
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
                    const Text(
                      'DRIVER WALLET BALANCE',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'First Bank •••• 4018',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '₦${_walletBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending Payout', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '₦${_pendingPayout.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This Week', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          SizedBox(height: 2),
                          Text(
                            '₦124,500',
                            style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _openCashoutModal,
                  child: const Text(
                    'CASHOUT / WITHDRAW FUNDS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Transactions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Earnings & Payouts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
              ),
              TextButton(
                onPressed: () => _toast('Viewing full ledger history'),
                child: const Text('View All', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Transactions List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _walletTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final txn = _walletTransactions[idx];
              final isCredit = txn['isCredit'] == true;
              final amount = txn['amount'] as double;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFDE4E4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txn['title'],
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            txn['subtitle'],
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isCredit ? "+" : "-"}₦${amount.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openCashoutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Withdraw to Bank Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Available balance: ₦${_walletBalance.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: AppColors.orange, size: 24),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Bank of Nigeria', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      Text('•••• 4018 (Instant Payout)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.yellow,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                final amount = _walletBalance;
                setState(() {
                  _walletBalance = 0;
                  _walletTransactions.insert(0, {
                    'title': 'Instant Bank Cashout',
                    'subtitle': 'Just now',
                    'amount': -amount,
                    'isCredit': false,
                  });
                });
                Navigator.pop(ctx);
                _toast('₦${amount.toStringAsFixed(0)} successfully transferred to your bank!');
              },
              child: const Text('CONFIRM INSTANT CASHOUT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.driverName.isNotEmpty
                              ? widget.driverName[0].toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            color: AppColors.yellow,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isVerified
                            ? Icons.verified_rounded
                            : Icons.hourglass_bottom_rounded,
                        color: widget.isVerified
                            ? const Color(0xFF10B981)
                            : AppColors.orange,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.driverName.isEmpty
                      ? 'Sekure Courier Driver'
                      : widget.driverName,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email.isEmpty
                      ? 'driver@sekurecourier.com'
                      : widget.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.isVerified
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isVerified
                        ? '★ VERIFIED COURIER'
                        : '⏳ VERIFICATION PENDING',
                    style: TextStyle(
                      color: widget.isVerified
                          ? const Color(0xFF2E7D32)
                          : AppColors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _ProfileMenuTile(
            icon: Icons.directions_bike_rounded,
            title: 'Vehicle Information',
            subtitle: 'Honda Ace 125 • Plate: LA-492-IKJ',
            onTap: () => _toast('Vehicle details up to date.'),
          ),
          _ProfileMenuTile(
            icon: Icons.account_balance_rounded,
            title: 'Bank & Payout Settings',
            subtitle: 'First Bank of Nigeria • **** 4018',
            onTap: () => _toast('Manage payout account'),
          ),
          _ProfileMenuTile(
            icon: Icons.support_agent_rounded,
            title: 'Driver Support 24/7',
            subtitle: 'Live Chat & Incident Reporting',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SupportChatScreen(isCourierSupport: true),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Sign Out Driver Account',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/logo1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.two_wheeler_rounded,
                    color: AppColors.yellow,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEKURE DRIVER',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Courier Console',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_rounded, color: AppColors.yellow),
            tooltip: 'Delivery Reminders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EventReminderScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.psychology_rounded, color: AppColors.yellow),
            tooltip: 'Sekure AI Copilot',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AiAssistantScreen(isCourierMode: true),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _toast('No new driver alerts'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildOverviewTab(),
          _buildWalletTab(),
          _buildDocumentsTab(),
          _buildHealthTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.lemon,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => setState(() => _selectedTab = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.black,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Deliveries',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_special_rounded),
              label: 'Verification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_rounded),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocStatusTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isVerified;
  final IconData icon;

  const _DocStatusTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isVerified,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.black, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFE8F5E9)
                  : AppColors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isVerified ? const Color(0xFF2E7D32) : AppColors.orange,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.orange),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
      ),
    );
  }
}

class _ErgonomicGuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ErgonomicGuideTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
