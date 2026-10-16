import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ai_assistant_screen.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';
import 'event_reminder_screen.dart';
import 'health_dashboard_screen.dart';
import 'support_chat_screen.dart';
import 'theme.dart';

/// Dashboard colours. Change them here.
class _C {
  static const bg = Colors.white;
  static const ink = Color(0xFF14211C);
  static const lime = Color(0xFFFFF44F); // lemon yellow
  static const muted = Color(0xFF5F6358);
  static const border = Color(0xFFE6D93A);
  static const green = Color(0xFF1B5E20);
  static const glow = Color(0xFFFFE600);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF98A), Color(0xFFFFEB1F)],
  );
}

class _Shipment {
  final String id, name, place, status;
  const _Shipment(this.id, this.name, this.place, this.status);
}

// Sample data: replace with your backend.
const _shipments = [
  _Shipment('WB-20481', 'Amara Okafor', 'Lokki, Lagos', 'In transit'),
  _Shipment('WB-20476', 'David Mensah', 'East Legon, Accra', 'Delivered'),
  _Shipment('WB-20469', 'Sade Williams', 'Wuse 2, Abuja', 'Processing'),
];

class _Txn {
  final int id;
  final String title, subtitle;
  final double amount; // negative = money out
  final IconData icon;
  final Color bg, fg;
  const _Txn(this.id, this.title, this.subtitle, this.amount, this.icon,
      this.bg, this.fg);
}

({Color bg, Color fg, IconData icon}) _statusStyle(String s) {
  switch (s) {
    case 'Delivered':
      return (
      bg: const Color(0xFFDFF3E3),
      fg: const Color(0xFF2E7D45),
      icon: Icons.check_rounded
      );
    case 'Processing':
      return (
      bg: const Color(0xFFFDE4E4),
      fg: const Color(0xFFD94545),
      icon: Icons.inventory_2_outlined
      );
    default:
      return (
      bg: const Color(0xFFDDF0FA),
      fg: const Color(0xFF1D6FA3),
      icon: Icons.inventory_2_outlined
      );
  }
}

BoxDecoration _cardDecoration([double r = 18]) => BoxDecoration(
  gradient: _C.gradient,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: _C.border.withValues(alpha: .5)),
  boxShadow: [
    BoxShadow(
      color: _C.glow.withValues(alpha: .35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ],
);

// ---------------------------------------------------------------- Screen
class DashboardScreen extends StatefulWidget {
  final String name; // full name, or email when logging in
  final String email;
  const DashboardScreen({super.key, required this.name, this.email = ''});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  bool _notifications = true;

  // Wallet (sample data: replace with your backend)
  double _balance = 24500;
  double _moneyIn = 65000;
  int _txnId = 100;
  final List<_Txn> _activity = [
    const _Txn(1, 'Waybill WB-20481', 'Delivery payment · Today, 10:24 AM',
        -4500, Icons.local_shipping_outlined, Color(0xFFFDE4E4), Color(0xFFD94545)),
    const _Txn(2, 'Wallet funded', 'Visa •••• 4082 · Yesterday, 4:12 PM',
        20000, Icons.add_rounded, Color(0xFFDFF3E3), Color(0xFF2E7D45)),
    const _Txn(3, 'Waybill WB-20469', 'Delivery payment · 18 Jan, 1:45 PM',
        -3800, Icons.inventory_2_outlined, Color(0xFFDDF0FA), Color(0xFF1D6FA3)),
  ];

  /// One-shot entrance animation (staggered sections).
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  /// Bottom bar slide-up (plays once, so the bar never disappears on tab changes).
  late final AnimationController _navIn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  /// Endless 6s loop (floating circles, truck, bell, shimmer, glow).
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _navIn.dispose();
    _loop.dispose();
    super.dispose();
  }

  String get _displayName {
    final raw = widget.name.trim();
    final base = raw.contains('@') ? raw.split('@').first : raw;
    final words = base.split(RegExp(r'[._\s]+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return 'there';
    return words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  String get _initials =>
      _displayName.split(' ').take(2).map((w) => w[0]).join().toUpperCase();

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';
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

  void _onNav(int i) {
    if (i == 2) {
      _snack('Create waybill: connect this to your backend.');
      return;
    }
    if ((i == 0 || i == 3 || i == 4) && _tab != i) _enter.forward(from: 0); // replay entrance
    setState(() => _tab = i);
  }

  Widget _page() {
    switch (_tab) {
      case 1:
        return _shipmentsPage();
      case 3:
        return _walletPage();
      case 4:
        return _accountPage();
      default:
        return _home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_tab), child: _page()),
        ),
      ),
      bottomNavigationBar: _Stagger(
        anim: _navIn,
        begin: 0,
        end: 1,
        dy: 70,
        child: _BottomNav(current: _tab, pulse: _loop, onTap: _onNav),
      ),
    );
  }

  // ---------------------------------------------------------------- Home
  Widget _home() {
    Widget st(double b, double e, Widget c, {double dx = 0, double dy = 28}) =>
        _Stagger(anim: _enter, begin: b, end: e, dx: dx, dy: dy, child: c);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        st(0, .35, _header()),
        const SizedBox(height: 24),
        st(.1, .55, _hero()),
        const SizedBox(height: 20),
        st(.18, .6, _customerHealthBanner()),
        const SizedBox(height: 24),
        st(.25, .6, _title('Shipment overview')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: st(
              .3,
              .7,
              const _StatCard(
                icon: Icons.inventory_2_outlined,
                value: 12,
                label: 'Total',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .37,
              .77,
              const _StatCard(
                icon: Icons.local_shipping_outlined,
                value: 3,
                label: 'In transit',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .44,
              .84,
              const _StatCard(
                icon: Icons.check_rounded,
                value: 8,
                label: 'Delivered',
              ),
            ),
          ),
        ]),
        const SizedBox(height: 28),
        st(.4, .75, _title('Quick actions')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: st(
              .45,
              .85,
              _ActionCard(
                icon: Icons.search_rounded,
                label: 'Track\npackage',
                onTap: () => _snack('Track package'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .52,
              .9,
              _ActionCard(
                icon: Icons.people_alt_outlined,
                label: 'Saved\nrecipients',
                onTap: () => _snack('Saved recipients'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .59,
              .95,
              _ActionCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Fund wallet',
                onTap: () => _onNav(3),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        st(
          .58,
          .92,
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AiAssistantScreen(isCourierMode: false),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF1E1E2C)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: _C.lime, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ask Sekure AI Copilot', style: TextStyle(color: _C.lime, fontWeight: FontWeight.w900, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Instant tracking, pricing & logistics intelligence', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        st(
          .6,
          .9,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title('Recent shipments'),
              _Pressable(
                onTap: () => setState(() => _tab = 1),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('View all',
                      style: TextStyle(
                          color: _C.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _shipmentList(animated: true),
      ],
    );
  }

  Widget _customerHealthBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'HEALTH & ECO IMPACT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🌱 Green Shipper',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3,420 Steps Walked',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '160 kcal burned walking to pickup points • 4.2 kg CO₂ saved',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.lime,
                  foregroundColor: _C.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _openCustomerHealthModal,
                child: const Text(
                  'VIEW HEALTH',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCustomerHealthModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HealthDashboardScreen(
          isCourierMode: false,
          userName: 'Customer',
        ),
      ),
    );
  }

  Widget _title(String t) => Text(t,
      style: const TextStyle(
          color: _C.ink, fontSize: 18, fontWeight: FontWeight.w800));

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _C.glow.withValues(alpha: .6),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: _C.lime,
            child: Text(_initials,
                style: const TextStyle(
                    color: _C.ink, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(_greeting,
                    style: const TextStyle(color: _C.muted, fontSize: 12)),
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _loop,
                  builder: (context, child) {
                    final p = _loop.value;
                    final wave =
                    p < .2 ? math.sin(p / .2 * math.pi * 5) * .5 : 0.0;
                    return Transform.rotate(
                      angle: wave,
                      alignment: Alignment.bottomRight,
                      child: const Text('👋', style: TextStyle(fontSize: 13)),
                    );
                  },
                ),
              ]),
              Text(_displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _C.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        _Pressable(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EventReminderScreen(),
              ),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _C.lime,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border.withValues(alpha: .5)),
              boxShadow: [
                BoxShadow(
                  color: _C.glow.withValues(alpha: .4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.alarm_rounded, color: _C.ink),
          ),
        ),
        _bell(),
      ],
    );
  }

  Widget _bell() {
    return _Pressable(
      onTap: () => _snack('No new notifications'),
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final p = _loop.value;
          final ring = p < .12
              ? math.sin(p / .12 * math.pi * 6) * (1 - p / .12) * .4
              : 0.0;
          final q = (p * 3) % 1; // pulse of the red dot
          final w = 8 + 14 * q;
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.lime,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border.withValues(alpha: .5)),
              boxShadow: [
                BoxShadow(
                  color: _C.glow.withValues(alpha: .4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: ring,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.notifications_none_rounded,
                      color: _C.ink),
                ),
                Positioned(
                  top: 11,
                  right: 12,
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -(w - 8) / 2,
                          top: -(w - 8) / 2,
                          child: Container(
                            width: w,
                            height: w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE5484D)
                                  .withValues(alpha: .5 * (1 - q)),
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5484D),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, child) {
        final a = _loop.value * 2 * math.pi;
        Widget circle(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: alpha),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _C.gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: _C.glow.withValues(alpha: .5),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70 + 12 * math.sin(a),
                right: -70 + 12 * math.cos(a),
                child: circle(170, .45),
              ),
              Positioned(
                bottom: -50 + 10 * math.cos(a),
                left: -40 + 14 * math.sin(a),
                child: circle(110, .30),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(0, -3 * math.sin(a * 2)),
                    child: Transform.rotate(
                      angle: .08 * math.sin(a * 2),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.description_outlined,
                            color: _C.ink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Send a package today',
                      style: TextStyle(
                          color: _C.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a waybill, schedule pickup and track delivery from one place.',
                    style:
                    TextStyle(color: _C.muted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _RouteStrip(p: _loop.value),
                  const SizedBox(height: 16),
                  _ShimmerButton(p: _loop.value, onTap: () => _onNav(2)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shipmentList({bool animated = false}) {
    return Container(
      decoration: _cardDecoration(22),
      child: Column(
        children: [
          for (var i = 0; i < _shipments.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: _C.border.withValues(alpha: .5)),
                () {
              final tile = _ShipmentTile(
                s: _shipments[i],
                onTap: () => _snack('Open ${_shipments[i].id}'),
              );
              return animated
                  ? _Stagger(
                anim: _enter,
                begin: .65 + .08 * i,
                end: .9 + .05 * i,
                dx: 40,
                dy: 0,
                child: tile,
              )
                  : tile;
            }(),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------- Other tabs
  Widget _shipmentsPage() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
    children: [
      _title('Shipments'),
      const SizedBox(height: 12),
      _shipmentList(),
    ],
  );

  // ------------------------------------------------------------ Wallet tab
  Widget _sectionRow(String title, String action, VoidCallback onTap) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _title(title),
      _Pressable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(action,
              style: const TextStyle(
                  color: _C.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    ],
  );

  Widget _walletPage() {
    Widget st(double b, double e, Widget c) =>
        _Stagger(anim: _enter, begin: b, end: e, child: c);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        st(
          0,
          .35,
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payments',
                      style: TextStyle(color: _C.muted, fontSize: 12)),
                  Text('My wallet',
                      style: TextStyle(
                          color: _C.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            _bell(),
          ]),
        ),
        const SizedBox(height: 20),
        st(.1, .55, _balanceCard()),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: st(
              .25,
              .65,
              _ActionButton(
                icon: Icons.add_rounded,
                label: 'Add money',
                primary: true,
                onTap: _openAddMoney,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .32,
              .72,
              _ActionButton(
                icon: Icons.send_rounded,
                label: 'Withdraw',
                onTap: () => _snack('Withdraw: connect this to your backend.'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .39,
              .79,
              _ActionButton(
                icon: Icons.description_outlined,
                label: 'Pay waybill',
                onTap: () => _snack('Pay waybill'),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 26),
        st(.4, .75,
            _sectionRow('This month', 'View report', () => _snack('Monthly report'))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: st(
              .45,
              .85,
              _FlowCard(
                icon: Icons.add_rounded,
                iconColor: const Color(0xFF2E7D45),
                label: 'Money in',
                amount: _moneyIn,
                sub: '+18% from last month',
                subColor: _C.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: st(
              .52,
              .9,
              const _FlowCard(
                icon: Icons.north_east_rounded,
                iconColor: Color(0xFFD94545),
                label: 'Money out',
                amount: 40500,
                sub: '8 delivery payments',
                subColor: _C.muted,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 26),
        st(.55, .9,
            _sectionRow('Payment method', 'Manage', () => _snack('Manage payment methods'))),
        const SizedBox(height: 12),
        st(.6, .95, _cardRow()),
        const SizedBox(height: 26),
        st(.65, 1,
            _sectionRow('Recent activity', 'See all', () => _snack('All activity'))),
        const SizedBox(height: 12),
        st(.7, 1, _activityList()),
      ],
    );
  }

  Widget _balanceCard() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, child) {
        final a = _loop.value * 2 * math.pi;
        final q = (_loop.value * 3) % 1; // status-dot pulse

        Widget ring(double size) => Transform.scale(
          scale: 1 + .05 * math.sin(a * 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: .35), width: 16),
            ),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _C.gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: _C.glow.withValues(alpha: .5),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(top: -70, right: -70, child: ring(170)),
              Positioned(top: -35, right: -35, child: ring(100)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available balance',
                                style:
                                TextStyle(color: _C.muted, fontSize: 13)),
                            const SizedBox(height: 6),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: _balance),
                              duration: const Duration(milliseconds: 1400),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, child) => FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(_money(v),
                                    style: const TextStyle(
                                        color: _C.ink,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: _C.ink),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: _C.ink.withValues(alpha: .12),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 8 + 8 * q,
                                height: 8 + 8 * q,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2E7D45)
                                      .withValues(alpha: .45 * (1 - q)),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D45),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Wallet active · ID 8402 1189',
                          style: TextStyle(
                              color: _C.ink.withValues(alpha: .7),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardRow() => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(20),
    child: Row(
      children: [
        Container(
          width: 56,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A6E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('VISA',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic)),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•••• 4082',
                  style: TextStyle(
                      color: _C.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 2),
              Text('Expires 09/28',
                  style: TextStyle(color: _C.muted, fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF3E3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Primary',
              style: TextStyle(
                  color: Color(0xFF2E7D45),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  Widget _activityList() {
    final items = _activity.take(5).toList();
    return Container(
      decoration: _cardDecoration(22),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
          // Keyed so only newly added rows play the slide-in.
            TweenAnimationBuilder<double>(
              key: ValueKey(items[i].id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, c) => Opacity(
                opacity: v,
                child: Transform.translate(
                    offset: Offset(0, -16 * (1 - v)), child: c),
              ),
              child: Column(
                children: [
                  if (i > 0)
                    Divider(height: 1, color: _C.border.withValues(alpha: .5)),
                  _TxnTile(t: items[i], onTap: () => _snack(items[i].title)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openAddMoney() async {
    var picked = 5000;
    final amount = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Add money',
                  style: TextStyle(
                      color: _C.ink, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Choose an amount to add from Visa •••• 4082.',
                  style: TextStyle(color: _C.muted, fontSize: 13)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final v in const [2000, 5000, 10000, 20000, 50000])
                    GestureDetector(
                      onTap: () => setSheet(() => picked = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: picked == v ? _C.lime : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: picked == v ? _C.ink : _C.border,
                            width: picked == v ? 1.6 : 1,
                          ),
                        ),
                        child: Text(_naira(v),
                            style: const TextStyle(
                                color: _C.ink, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(ctx, picked),
                  child: const Text('Add money',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (amount == null || !mounted) return;
    setState(() {
      _balance += amount;
      _moneyIn += amount;
      _activity.insert(
        0,
        _Txn(_txnId++, 'Wallet funded', 'Visa •••• 4082 · Just now',
            amount.toDouble(), Icons.add_rounded, const Color(0xFFDFF3E3),
            const Color(0xFF2E7D45)),
      );
    });
    _snack('${_naira(amount)} added to your wallet');
  }

  // ----------------------------------------------------------- Account tab
  Widget _accountPage() {
    Widget st(double b, double e, Widget c) =>
        _Stagger(anim: _enter, begin: b, end: e, child: c);
    final email = widget.email.isNotEmpty
        ? widget.email
        : (widget.name.contains('@') ? widget.name.trim() : '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        st(
          0,
          .35,
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your profile',
                      style: TextStyle(color: _C.muted, fontSize: 12)),
                  Text('Account',
                      style: TextStyle(
                          color: _C.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            _bell(),
          ]),
        ),
        const SizedBox(height: 20),
        st(.1, .55, _profileCard(email)),
        const SizedBox(height: 16),
        st(.25, .65, _walletCard()),
        const SizedBox(height: 26),
        st(.35, .7, _sectionLabel('ACCOUNT')),
        const SizedBox(height: 10),
        st(
          .4,
          .8,
          _settingsCard([
            _SettingTile(
              icon: Icons.people_alt_outlined,
              title: 'Personal information',
              subtitle: 'Name, email and phone',
              onTap: () => _snack('Personal information'),
            ),
            _SettingTile(
              icon: Icons.location_on_outlined,
              title: 'Saved addresses',
              subtitle: '2 delivery addresses',
              onTap: () => _snack('Saved addresses'),
            ),
            _SettingTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payment methods',
              subtitle: 'Visa ending in 4082',
              onTap: () => _snack('Payment methods'),
            ),
            _SettingTile(
              icon: Icons.health_and_safety_rounded,
              title: 'Health & Wellness Dashboard',
              subtitle: 'Steps, eco carbon impact & ergonomics',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HealthDashboardScreen(
                      isCourierMode: false,
                      userName: 'Customer',
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
        const SizedBox(height: 26),
        st(.5, .85, _sectionLabel('PREFERENCES')),
        const SizedBox(height: 10),
        st(
          .55,
          .9,
          _settingsCard([
            _SettingTile(
              icon: Icons.notifications_none_rounded,
              title: 'Shipment notifications',
              subtitle: 'Push, email and SMS',
              onTap: () => setState(() => _notifications = !_notifications),
              trailing: Switch(
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
                trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
                trackColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? _C.ink
                    : Colors.white),
                thumbColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? _C.lime
                    : _C.muted),
              ),
            ),
            _SettingTile(
              icon: Icons.description_outlined,
              title: 'Waybill preferences',
              subtitle: 'Defaults and packaging',
              onTap: () => _snack('Waybill preferences'),
            ),
            _SettingTile(
              icon: Icons.support_agent_outlined,
              title: 'Help & support',
              subtitle: '24/7 Live Customer Care Chat',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupportChatScreen(isCourierSupport: false),
                  ),
                );
              },
            ),
          ]),
        ),
        const SizedBox(height: 24),
        st(.7, 1, _signOutButton()),
        const SizedBox(height: 14),
        st(
          .8,
          1,
          const Center(
            child: Text('Sekure Courier app · Version 1.0.0',
                style: TextStyle(color: _C.muted, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(
          color: _C.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3));

  Widget _settingsCard(List<Widget> tiles) => Container(
    decoration: _cardDecoration(20),
    child: Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: _C.border.withValues(alpha: .5)),
          tiles[i],
        ],
      ],
    ),
  );

  Widget _profileCard(String email) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, child) {
        final a = _loop.value * 2 * math.pi;
        Widget circle(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: alpha),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(26),
          child: Stack(
            children: [
              Positioned(
                top: -60 + 10 * math.sin(a),
                right: -60 + 10 * math.cos(a),
                child: circle(150, .4),
              ),
              Positioned(
                bottom: -50 + 8 * math.cos(a),
                left: -30 + 10 * math.sin(a),
                child: circle(90, .25),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .12),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(_initials,
                              style: const TextStyle(
                                  color: _C.ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(_displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: _C.ink,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded,
                                    size: 19, color: Color(0xFF2E7D45)),
                              ],
                            ),
                            if (email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: _C.muted, fontSize: 13)),
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('VERIFIED CUSTOMER',
                                  style: TextStyle(
                                      color: _C.ink,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: _C.ink.withValues(alpha: .12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 12),
                              duration: const Duration(milliseconds: 1400),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, child) => Text(
                                v.round().toString(),
                                style: const TextStyle(
                                    color: _C.ink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Text('Total shipments',
                                style:
                                TextStyle(color: _C.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 38,
                          color: _C.ink.withValues(alpha: .12)),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dec 2024',
                                  style: TextStyle(
                                      color: _C.ink,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800)),
                              Text('Customer since',
                                  style: TextStyle(
                                      color: _C.muted, fontSize: 12)),
                            ],
                          ),
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
    );
  }

  Widget _walletCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(20),
    child: Row(
      children: [
        const _IconBox(
          icon: Icons.account_balance_wallet_outlined,
          bg: Colors.white,
          color: _C.ink,
          size: 42,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wallet balance',
                  style: TextStyle(color: _C.muted, fontSize: 12)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _balance),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Text(_money(v),
                    style: const TextStyle(
                        color: _C.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        _Pressable(
          onTap: _openAddMoney,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _C.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Add funds',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ),
  );

  Widget _signOutButton() => _Pressable(
    onTap: _confirmSignOut,
    child: Container(
      height: 52,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFDE4E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3B8B8)),
      ),
      child: const Text('Sign out',
          style: TextStyle(
              color: Color(0xFFD94545),
              fontWeight: FontWeight.w800,
              fontSize: 15)),
    ),
  );

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Sign out?',
            style: TextStyle(color: _C.ink, fontWeight: FontWeight.w800)),
        content: const Text('You will need to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _C.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out',
                style: TextStyle(
                    color: Color(0xFFD94545), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
            (_) => false,
      );
    }
  }
}

// ------------------------------------------------------- Animation helpers
/// Fades + slides its child in during [begin]..[end] of [anim].
class _Stagger extends StatelessWidget {
  final Animation<double> anim;
  final double begin, end, dx, dy;
  final Widget child;
  const _Stagger({
    required this.anim,
    required this.begin,
    required this.end,
    this.dx = 0,
    this.dy = 28,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curve = Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (_, ch) {
        final t = curve.transform(anim.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(dx * (1 - t), dy * (1 - t)),
            child: ch,
          ),
        );
      },
    );
  }
}

/// Shrinks slightly while pressed.
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

/// Dashed delivery route with a truck driving along it.
class _RouteStrip extends StatelessWidget {
  final double p; // 0..1 loop value
  const _RouteStrip({required this.p});

  Widget _dot(IconData icon) => Container(
    width: 20,
    height: 20,
    decoration:
    const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, size: 13, color: _C.ink),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const pad = 14.0, truck = 30.0;
      final w = c.maxWidth;
      final prog = (p * 2) % 1;
      final x = pad + (w - 2 * pad - truck) * Curves.easeInOut.transform(prog);
      final dashes = ((w - 2 * pad) / 12).floor();

      return SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: pad,
              right: pad,
              top: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  dashes,
                      (_) => Container(
                    width: 6,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: _C.ink.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(left: 0, top: 6, child: _dot(Icons.location_on_rounded)),
            Positioned(right: 0, top: 6, child: _dot(Icons.home_rounded)),
            Positioned(
              left: x,
              top: 1,
              child: Opacity(
                opacity: (math.min(prog, 1 - prog) * 8).clamp(0.0, 1.0),
                child: Container(
                  width: truck,
                  height: truck,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      size: 17, color: _C.ink),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// White button with a light sweep passing over it.
class _ShimmerButton extends StatelessWidget {
  final double p;
  final VoidCallback onTap;
  const _ShimmerButton({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          width: double.infinity,
          color: Colors.white,
          child: LayoutBuilder(builder: (context, c) {
            final x = -80 + (c.maxWidth + 160) * ((p * 1.5) % 1);
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: x,
                  top: 0,
                  bottom: 0,
                  width: 60,
                  child: Transform(
                    transform: Matrix4.skewX(-.4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          _C.lime.withValues(alpha: .9),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: _C.ink),
                    SizedBox(width: 8),
                    Text('Create new waybill',
                        style: TextStyle(
                            color: _C.ink, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Widgets
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg, color;
  final double size;
  const _IconBox(
      {required this.icon,
        required this.bg,
        required this.color,
        this.size = 34});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(size / 3),
    ),
    child: Icon(icon, color: color, size: size * .52),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon pops in
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (_, v, c) => Transform.scale(scale: v, child: c),
          child: _IconBox(icon: icon, bg: Colors.white, color: _C.ink),
        ),
        const SizedBox(height: 16),
        // Number counts up
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Text(v.round().toString(),
              style: const TextStyle(
                  color: _C.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
        ),
        Text(label,
            style: const TextStyle(color: _C.muted, fontSize: 12)),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => _Pressable(
    onTap: onTap,
    child: Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconBox(icon: icon, bg: Colors.white, color: _C.ink),
          Text(label,
              style: const TextStyle(
                  color: _C.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2)),
        ],
      ),
    ),
  );
}

class _ShipmentTile extends StatelessWidget {
  final _Shipment s;
  final VoidCallback onTap;
  const _ShipmentTile({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = _statusStyle(s.status);
    return _Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _IconBox(icon: st.icon, bg: st.bg, color: st.fg, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(s.id,
                          style: const TextStyle(
                              color: _C.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: st.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s.status,
                            style: TextStyle(
                                color: st.fg,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(s.name,
                      style: const TextStyle(color: _C.ink, fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: _C.muted),
                      const SizedBox(width: 3),
                      Text(s.place,
                          style:
                          const TextStyle(color: _C.muted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (s.status == 'In transit')
              IconButton(
                icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.orange),
                tooltip: 'Chat with Courier',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        orderId: s.id,
                        peerName: s.name,
                        peerRole: 'Courier',
                        peerPhone: '+234 803 444 5566',
                        vehicleInfo: 'Honda Ace 125 • LA-492-IKJ',
                      ),
                    ),
                  );
                },
              ),
            const Icon(Icons.chevron_right_rounded, color: _C.muted),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final Animation<double> pulse;
  final ValueChanged<int> onTap;
  const _BottomNav(
      {required this.current, required this.pulse, required this.onTap});

  Widget _item(int i, IconData off, IconData on, String label) {
    final sel = current == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? _C.lime : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: sel
                  ? [
                BoxShadow(
                  color: _C.glow.withValues(alpha: .5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : const [],
            ),
            child: AnimatedScale(
              scale: sel ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(sel ? on : off,
                  size: 22, color: sel ? _C.ink : _C.muted),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
                fontSize: 11,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? _C.ink : _C.muted),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _C.border.withValues(alpha: .4))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _item(1, Icons.inventory_2_outlined, Icons.inventory_2_rounded,
                  'Shipments'),
              _Pressable(
                onTap: () => onTap(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: pulse,
                      builder: (context, child) {
                        final s =
                            (math.sin(pulse.value * 2 * math.pi * 3) + 1) / 2;
                        return Container(
                          width: 54,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _C.lime,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _C.border),
                            boxShadow: [
                              BoxShadow(
                                color:
                                _C.glow.withValues(alpha: .35 + .35 * s),
                                blurRadius: 10 + 12 * s,
                                spreadRadius: 1 + 2 * s,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: _C.ink, size: 26),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    const Text('Create',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _C.muted)),
                  ],
                ),
              ),
              _item(3, Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet_rounded, 'Wallet'),
              _item(4, Icons.settings_outlined, Icons.settings_rounded,
                  'Account'),
            ],
          ),
        ),
      ),
    );
  }
}

String _money(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final whole =
  parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '₦$whole.${parts[1]}';
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => _Pressable(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: Colors.white, color: _C.ink, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _C.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                    const TextStyle(color: _C.muted, fontSize: 12)),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right_rounded, color: _C.muted),
        ],
      ),
    ),
  );
}

String _naira(num v) {
  final digits = v.round().toString();
  final whole =
  digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '₦$whole';
}

String _signed(double a) => (a < 0 ? '−' : '+') + _naira(a.abs());

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) => _Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _cardDecoration(20),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary ? _C.ink : Colors.white,
            ),
            child: Icon(icon, color: primary ? _C.lime : _C.ink, size: 22),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  color: _C.ink, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _FlowCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, subColor;
  final String label, sub;
  final double amount;
  const _FlowCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _IconBox(icon: icon, bg: Colors.white, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: _C.muted, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: amount),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_naira(v),
                style: const TextStyle(
                    color: _C.ink, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 4),
        Text(sub,
            style: TextStyle(
                color: subColor, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _TxnTile extends StatelessWidget {
  final _Txn t;
  final VoidCallback onTap;
  const _TxnTile({required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) => _Pressable(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: t.icon, bg: t.bg, color: t.fg, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                        color: _C.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(t.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _C.muted, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_signed(t.amount),
              style: TextStyle(
                  color: t.amount > 0 ? _C.green : _C.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    ),
  );
}