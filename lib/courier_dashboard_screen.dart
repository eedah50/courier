import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ai_assistant_screen.dart';
import 'chat_screen.dart';
import 'event_reminder_screen.dart';
import 'health_dashboard_screen.dart';
import 'role_selection_screen.dart';
import 'support_chat_screen.dart';
import 'theme.dart';
import 'courier_navigation_pickup_screen.dart';
import 'courier_earnings_screen.dart';
import 'courier_withdraw_screen.dart';
import 'courier_trip_history_screen.dart';
import 'courier_ratings_screen.dart';

/// Courier console colours. Same palette as the customer dashboard.
class _C {
  static const bg = Color(0xFFF6F5EF);
  static const ink = AppColors.black;
  static const lime = AppColors.lemon;
  static const muted = Color(0xFF6B6E64);
  static const green = Color(0xFF1B5E20);
  static const greenBg = Color(0xFFE3F4E6);
  static const red = Color(0xFFD94545);
  static const amber = Color(0xFF8A5A00);
  static const amberBg = Color(0xFFFFF1CC);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF98A), Color(0xFFFFEB1F)],
  );
  static const dark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF262626), AppColors.black],
  );
}

class _Order {
  final String id, pickup, dropoff, distance, package;
  final int payout;
  final bool urgent;
  const _Order(this.id, this.pickup, this.dropoff, this.distance, this.package,
      this.payout, this.urgent);
}

class _Txn {
  final String title, subtitle;
  final double amount; // negative = money out
  const _Txn(this.title, this.subtitle, this.amount);
}

BoxDecoration _card([double r = 22]) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: Colors.black.withValues(alpha: .06)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: .045),
      blurRadius: 18,
      offset: const Offset(0, 7),
    ),
  ],
);

BoxDecoration _darkCard([double r = 28]) => BoxDecoration(
  gradient: _C.dark,
  borderRadius: BorderRadius.circular(r),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: .22),
      blurRadius: 26,
      offset: const Offset(0, 12),
    ),
  ],
);

String _naira(num v) {
  final digits = v.abs().round().toString();
  final whole =
  digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '₦$whole';
}

// ---------------------------------------------------------------- Screen
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

class _CourierDashboardScreenState extends State<CourierDashboardScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  bool _online = true;

  // Health (sample data: replace with your backend)
  double _water = 1.8;
  final int _steps = 8650;
  bool _rest = false;

  // Wallet (sample data: replace with your backend)
  double _balance = 48500;
  final double _pending = 14200;
  int _today = 18500;
  int _trips = 14;
  final List<_Txn> _txns = [
    const _Txn('Trip payout #SKR-8842', 'Today, 11:30 AM', 4500),
    const _Txn('Weekly performance bonus', 'Yesterday, 9:00 PM', 5000),
    const _Txn('Trip payout #SKR-8839', 'Yesterday, 4:15 PM', 3800),
    const _Txn('Bank withdrawal (First Bank)', '16 Jan, 10:00 AM', -30000),
  ];

  final List<_Order> _orders = [
    const _Order('SKR-8842', '12 Ikeja City Mall, Lagos',
        '45 Victoria Island, Lagos', '6.4 km', 'Electronics box · 2.5 kg', 4500, true),
    const _Order('SKR-8845', '8 Allen Avenue, Ikeja',
        '18 Maryland Estate, Lagos', '3.2 km', 'Legal documents · 0.4 kg', 2800, false),
    const _Order('SKR-8849', 'Lekki Phase 1, Gate 2', 'Chevron Drive, Lekki',
        '8.1 km', 'Gift hamper · 4.1 kg', 5200, true),
  ];

  _Order? _active;
  int _stage = 0; // 0 = heading to pickup, 1 = package on board

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- Helpers
  bool get _available => _online && !_rest;

  String get _name =>
      widget.driverName.trim().isEmpty ? 'Sekure Driver' : widget.driverName.trim();

  String get _initials {
    final parts = _name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return parts.take(2).map((w) => w[0]).join().toUpperCase();
  }

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

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _onNav(int i) {
    if (i == _tab) return;
    HapticFeedback.selectionClick();
    _enter.forward(from: 0);
    setState(() => _tab = i);
  }

  Widget _st(double b, double e, Widget c, {double dx = 0, double dy = 24}) =>
      _Stagger(anim: _enter, begin: b, end: e, dx: dx, dy: dy, child: c);

  void _openChat(_Order o) => _push(ChatScreen(
    orderId: o.id,
    peerName: 'Amara Okafor',
    peerRole: 'Customer',
    peerPhone: '+234 802 111 2233',
    vehicleInfo: 'Waybill recipient',
  ));

  // ----------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_tab) {
      case 1:
        page = _walletPage();
        break;
      case 2:
        page = _verificationPage();
        break;
      case 3:
        page = _healthPage();
        break;
      case 4:
        page = _profilePage();
        break;
      default:
        page = _homePage();
    }

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .03),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_tab), child: page),
        ),
      ),
      bottomNavigationBar: _BottomNav(current: _tab, onTap: _onNav),
    );
  }

  // ------------------------------------------------------- Shared pieces
  Widget _roundBtn(IconData icon, VoidCallback onTap, {String? tip}) {
    final btn = _Pressable(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: .07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: _C.ink, size: 21),
      ),
    );
    return tip == null ? btn : Tooltip(message: tip, child: btn);
  }

  Widget _bell() => Stack(
    clipBehavior: Clip.none,
    children: [
      _roundBtn(Icons.notifications_none_rounded,
              () => _snack('No new driver alerts'),
          tip: 'Alerts'),
      Positioned(
        top: 9,
        right: 10,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _C.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
      ),
    ],
  );

  Widget _pageHeader(String eyebrow, String title, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow,
                style: const TextStyle(color: _C.muted, fontSize: 12.5)),
            Text(title,
                style: const TextStyle(
                    color: _C.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5)),
          ],
        ),
      ),
      trailing ?? _bell(),
    ],
  );

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          color: _C.ink,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -.2));

  Widget _pill(String text, {Color? bg, Color fg = _C.ink, IconData? icon}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg ?? _C.lime.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 5),
            ],
            Text(text,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      );

  Widget _glow(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [
        _C.lime.withValues(alpha: alpha),
        _C.lime.withValues(alpha: 0),
      ]),
    ),
  );

  Widget _empty(IconData icon, String title, String msg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
    decoration: _card(24),
    child: Column(
      children: [
        _IconBox(icon: icon, bg: _C.lime.withValues(alpha: .5), color: _C.ink, size: 58),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(
                color: _C.ink, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _C.muted, fontSize: 13, height: 1.4)),
      ],
    ),
  );

  // ------------------------------------------------------------ Home tab
  Widget _homePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _st(0, .3, _homeHeader()),
        const SizedBox(height: 20),
        _st(.06, .5, _statusHero()),
        const SizedBox(height: 16),
        if (!widget.isVerified) ...[
          _st(.14, .55, _verifyBanner()),
          const SizedBox(height: 16),
        ],
        if (_active != null) ...[
          _st(.18, .6, _activeCard(_active!)),
          const SizedBox(height: 16),
        ],
        _st(.22, .62, _statsRow()),
        const SizedBox(height: 16),
        _st(
          .25,
          .65,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: .08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Courier Workflow & Console Hub', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: _C.ink)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _C.ink, foregroundColor: _C.lime, padding: const EdgeInsets.symmetric(vertical: 10)),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierEarningsScreen())),
                        child: const Text('Earnings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _C.lime, foregroundColor: _C.ink, padding: const EdgeInsets.symmetric(vertical: 10)),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierWithdrawScreen())),
                        child: const Text('Payouts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: _C.ink, side: const BorderSide(color: _C.ink), padding: const EdgeInsets.symmetric(vertical: 10)),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierTripHistoryScreen())),
                        child: const Text('Trip History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: _C.ink, side: const BorderSide(color: _C.ink), padding: const EdgeInsets.symmetric(vertical: 10)),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierRatingsScreen())),
                        child: const Text('Ratings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        _st(
          .3,
          .7,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Delivery requests'),
              if (_available) _pill('${_orders.length} nearby'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!_available)
          _st(
            .34,
            .76,
            _empty(
              _rest ? Icons.coffee_rounded : Icons.power_settings_new_rounded,
              _rest ? 'You are on a rest break' : 'You are offline',
              _rest
                  ? 'Requests are paused. Resume from the Health tab when you are ready.'
                  : 'Go online above to start receiving delivery requests.',
            ),
          )
        else if (_orders.isEmpty)
          _st(
            .34,
            .76,
            _empty(Icons.radar_rounded, 'Scanning for orders',
                'New requests near you will appear here.'),
          )
        else
          for (var i = 0; i < _orders.length; i++)
            _Stagger(
              anim: _enter,
              begin: .34 + .08 * i,
              end: .76 + .06 * i,
              dx: 40,
              dy: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _orderCard(_orders[i]),
              ),
            ),
      ],
    );
  }

  Widget _homeHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _C.lime,
          boxShadow: [
            BoxShadow(
              color: _C.lime.withValues(alpha: .7),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 21,
          backgroundColor: _C.ink,
          child: Text(_initials,
              style: const TextStyle(
                  color: _C.lime, fontWeight: FontWeight.w900)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting,
                style: const TextStyle(color: _C.muted, fontSize: 12.5)),
            Row(
              children: [
                Flexible(
                  child: Text(_name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _C.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.3)),
                ),
                if (widget.isVerified) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.verified_rounded,
                      size: 17, color: _C.green),
                ],
              ],
            ),
          ],
        ),
      ),
      _roundBtn(Icons.alarm_rounded,
              () => _push(const EventReminderScreen()),
          tip: 'Delivery reminders'),
      const SizedBox(width: 8),
      _roundBtn(Icons.psychology_rounded,
              () => _push(const AiAssistantScreen(isCourierMode: true)),
          tip: 'Sekure AI Copilot'),
      const SizedBox(width: 8),
      _bell(),
    ],
  );

  Widget _statusHero() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final a = _loop.value * 2 * math.pi;
        final on = _available;

        Widget ring(double phase) {
          final q = (_loop.value * 1.5 + phase) % 1;
          return Container(
            width: 56 + 52 * q,
            height: 56 + 52 * q,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: _C.lime.withValues(alpha: .5 * (1 - q)), width: 1.6),
            ),
          );
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(22),
          decoration: _darkCard(30),
          child: Stack(
            children: [
              Positioned(
                top: -80 + 14 * math.sin(a),
                right: -70 + 14 * math.cos(a),
                child: _glow(240, on ? .4 : .12),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 108,
                        height: 108,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (on) ...[ring(0), ring(.5)],
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: on ? _C.lime : Colors.white12,
                                shape: BoxShape.circle,
                                boxShadow: on
                                    ? [
                                  BoxShadow(
                                    color: _C.lime.withValues(alpha: .5),
                                    blurRadius: 18,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Icon(
                                on
                                    ? Icons.two_wheeler_rounded
                                    : Icons.power_settings_new_rounded,
                                color: on ? _C.ink : Colors.white54,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: .16)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _rest
                                          ? const Color(0xFFFFB020)
                                          : (_online ? _C.lime : _C.red),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _rest
                                        ? 'ON BREAK'
                                        : (_online ? 'ONLINE' : 'OFFLINE'),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              on
                                  ? 'Finding orders near you'
                                  : (_rest
                                  ? 'Taking a breather'
                                  : 'Ready when you are'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.4,
                                  height: 1.15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              on
                                  ? 'Ikeja zone · 5 km radius'
                                  : (_rest
                                  ? 'Requests are paused'
                                  : 'Go online to get requests'),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Pressable(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _online = !_online;
                        if (!_online) _rest = false;
                      });
                      _snack(_online
                          ? 'You are online. Requests will start coming in.'
                          : 'You are now offline.');
                    },
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _online ? Colors.white12 : _C.lime,
                        borderRadius: BorderRadius.circular(16),
                        border: _online
                            ? Border.all(color: Colors.white24)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _online
                                ? Icons.stop_circle_outlined
                                : Icons.play_arrow_rounded,
                            color: _online ? Colors.white : _C.ink,
                          ),
                          const SizedBox(width: 8),
                          Text(_online ? 'Go offline' : 'Go online',
                              style: TextStyle(
                                  color: _online ? Colors.white : _C.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _verifyBanner() => _Pressable(
    onTap: () => _onNav(2),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.amberBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF2D58A)),
      ),
      child: Row(
        children: [
          const _IconBox(
            icon: Icons.hourglass_top_rounded,
            bg: Colors.white,
            color: _C.amber,
            size: 44,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification under review',
                    style: TextStyle(
                        color: _C.ink,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('You can browse orders while we check your documents.',
                    style: TextStyle(
                        color: Color(0xFF6B5200), fontSize: 12, height: 1.35)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _C.amber),
        ],
      ),
    ),
  );

  Widget _statsRow() {
    Widget stat(IconData icon, Widget value, String label, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _card(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(icon: icon, bg: _C.lime, color: _C.ink, size: 36),
              const SizedBox(height: 12),
              value,
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _C.muted, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );

    const valueStyle = TextStyle(
        color: _C.ink, fontSize: 18, fontWeight: FontWeight.w900, height: 1.1);

    return Row(
      children: [
        stat(
          Icons.account_balance_wallet_outlined,
          TweenAnimationBuilder<double>(
            key: ValueKey(_today),
            tween: Tween(begin: 0, end: _today.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(_naira(v), style: valueStyle),
            ),
          ),
          'Earned today',
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierEarningsScreen())),
        ),
        const SizedBox(width: 10),
        stat(
          Icons.check_circle_outline_rounded,
          Text('$_trips', style: valueStyle),
          'Trips done',
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierTripHistoryScreen())),
        ),
        const SizedBox(width: 10),
        stat(
          Icons.star_rounded,
          const Text('4.9', style: valueStyle),
          'Your rating',
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourierRatingsScreen())),
        ),
      ],
    );
  }

  // ------------------------------------------------------- Order + active
  Widget _routeLine(String pickup, String dropoff, {bool onDark = false}) {
    final main = onDark ? Colors.white : _C.ink;
    final sub = onDark ? Colors.white54 : _C.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 3),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: main, width: 2.5),
              ),
            ),
            Container(
                width: 2, height: 34, color: main.withValues(alpha: .18)),
            Icon(Icons.location_on_rounded, size: 18, color: main),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PICKUP',
                  style: TextStyle(
                      color: sub,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              const SizedBox(height: 2),
              Text(pickup,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: main, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Text('DROP-OFF',
                  style: TextStyle(
                      color: sub,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              const SizedBox(height: 2),
              Text(dropoff,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: main, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _orderCard(_Order o) {
    Widget chip(IconData icon, String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _C.muted),
          const SizedBox(width: 5),
          Text(t,
              style: const TextStyle(
                  color: _C.ink, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(26).copyWith(
        border: Border.all(
          color: o.urgent
              ? _C.ink.withValues(alpha: .55)
              : Colors.black.withValues(alpha: .06),
          width: o.urgent ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _C.ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(o.id,
                    style: const TextStyle(
                        color: _C.lime,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900)),
              ),
              if (o.urgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.lime,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 13, color: _C.ink),
                      SizedBox(width: 2),
                      Text('EXPRESS',
                          style: TextStyle(
                              color: _C.ink,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(_naira(o.payout),
                  style: const TextStyle(
                      color: _C.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5)),
            ],
          ),
          const SizedBox(height: 18),
          _routeLine(o.pickup, o.dropoff),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip(Icons.alt_route_rounded, o.distance),
              chip(Icons.inventory_2_outlined, o.package),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Pressable(
                onTap: () => _openChat(o),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: _C.ink, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pressable(
                  onTap: () => _accept(o),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _C.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Accept delivery',
                        style: TextStyle(
                            color: _C.lime,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _accept(_Order o) {
    if (_active != null) {
      _snack('Finish your current delivery before accepting another.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _active = o;
      _stage = 0;
      _orders.remove(o);
    });
    _snack('Delivery ${o.id} accepted. Opening pickup navigation...');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourierNavigationPickupScreen(
          orderId: o.id,
          pickupAddress: o.pickup,
          distance: o.distance,
          payout: o.payout,
        ),
      ),
    );
  }

  Widget _activeCard(_Order o) {
    final pickedUp = _stage == 1;

    Widget step(int i, String label) {
      final done = i < _stage, now = i == _stage;
      return Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 3,
                        color: i == 0
                            ? Colors.transparent
                            : _C.ink.withValues(alpha: i <= _stage ? 1 : .2))),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? _C.ink : (now ? Colors.white : Colors.transparent),
                    border: Border.all(
                        color: _C.ink.withValues(alpha: done || now ? 1 : .3),
                        width: now ? 2.4 : 1.5),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, size: 13, color: _C.lime)
                      : null,
                ),
                Expanded(
                    child: Container(
                        height: 3,
                        color: i == 2
                            ? Colors.transparent
                            : _C.ink.withValues(alpha: i < _stage ? 1 : .2))),
              ],
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: _C.ink.withValues(alpha: i <= _stage ? 1 : .55),
                    fontSize: 11,
                    fontWeight: now ? FontWeight.w900 : FontWeight.w700)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: _C.gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _C.lime.withValues(alpha: .5),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.navigation_rounded, color: _C.ink, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('ACTIVE DELIVERY · ${o.id}',
                    style: const TextStyle(
                        color: _C.ink,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1)),
              ),
              Text(_naira(o.payout),
                  style: const TextStyle(
                      color: _C.ink, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          Text(pickedUp ? 'Deliver to' : 'Pick up from',
              style: TextStyle(
                  color: _C.ink.withValues(alpha: .65),
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(pickedUp ? o.dropoff : o.pickup,
              style: const TextStyle(
                  color: _C.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3)),
          const SizedBox(height: 16),
          Row(children: [
            step(0, 'To pickup'),
            step(1, 'On board'),
            step(2, 'Delivered'),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              _Pressable(
                onTap: () => _openChat(o),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded,
                      color: _C.ink, size: 21),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pressable(
                  onTap: pickedUp
                      ? _completeDelivery
                      : () {
                    HapticFeedback.mediumImpact();
                    setState(() => _stage = 1);
                    _snack('Pickup confirmed. Head to the drop-off point.');
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _C.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            pickedUp
                                ? Icons.check_circle_outline_rounded
                                : Icons.qr_code_scanner_rounded,
                            color: _C.lime,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(pickedUp ? 'Complete delivery' : 'Confirm pickup',
                            style: const TextStyle(
                                color: _C.lime,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5)),
                      ],
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

  void _completeDelivery() {
    final o = _active;
    if (o == null) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _balance += o.payout;
      _today += o.payout;
      _trips += 1;
      _txns.insert(0, _Txn('Trip payout #${o.id}', 'Just now', o.payout.toDouble()));
      _active = null;
      _stage = 0;
    });
    _snack('Delivered! ${_naira(o.payout)} added to your wallet.');
  }

  // ---------------------------------------------------------- Wallet tab
  Widget _walletPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _st(0, .35, _pageHeader('Earnings', 'My wallet')),
        const SizedBox(height: 20),
        _st(.1, .55, _balanceCard()),
        const SizedBox(height: 14),
        _st(
          .25,
          .7,
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.trending_up_rounded,
                  label: 'This week',
                  value: '₦124,500',
                  sub: '+12% vs last week',
                  subColor: _C.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.schedule_rounded,
                  label: 'Pending payout',
                  value: _naira(_pending),
                  sub: 'Clears within 24h',
                  subColor: _C.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        _st(
          .35,
          .75,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Recent earnings'),
              _Pressable(
                onTap: () => _snack('Full ledger history'),
                child: _pill('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _st(
          .42,
          .85,
          Container(
            decoration: _card(24),
            child: Column(
              children: [
                for (var i = 0; i < _txns.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: Colors.black.withValues(alpha: .06)),
                  _txnTile(_txns[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _balanceCard() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final a = _loop.value * 2 * math.pi;
        Widget ring(double size) => Transform.scale(
          scale: 1 + .05 * math.sin(a * 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: _C.lime.withValues(alpha: .16), width: 16),
            ),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(22),
          decoration: _darkCard(30),
          child: Stack(
            children: [
              Positioned(top: -70, right: -70, child: ring(170)),
              Positioned(top: -35, right: -35, child: ring(100)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('AVAILABLE BALANCE',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3)),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _C.lime,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: _C.ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_balance),
                    tween: Tween(begin: 0, end: _balance),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_naira(v),
                          style: const TextStyle(
                              color: _C.lime,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.account_balance_rounded,
                          size: 14, color: Colors.white54),
                      SizedBox(width: 6),
                      Text('First Bank •••• 4018',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Pressable(
                    onTap: _openCashout,
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _C.lime,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.north_east_rounded, color: _C.ink),
                          SizedBox(width: 8),
                          Text('Withdraw to bank',
                              style: TextStyle(
                                  color: _C.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _txnTile(_Txn t) {
    final credit = t.amount > 0;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(
            icon: credit ? Icons.south_west_rounded : Icons.north_east_rounded,
            bg: credit ? _C.lime : const Color(0xFFEDEBE0),
            color: _C.ink,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _C.ink, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(t.subtitle,
                    style: const TextStyle(color: _C.muted, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${credit ? '+' : '−'}${_naira(t.amount)}',
              style: TextStyle(
                  color: credit ? _C.green : _C.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Future<void> _openCashout() async {
    final amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => _CashoutSheet(balance: _balance),
    );
    if (amount == null || !mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _balance -= amount;
      _txns.insert(0, _Txn('Bank withdrawal (First Bank)', 'Just now', -amount.toDouble()));
    });
    _snack('${_naira(amount)} is on its way to your bank.');
  }

  // ---------------------------------------------------- Verification tab
  Widget _verificationPage() {
    const docs = <({String title, String sub, IconData icon})>[
      (title: 'Government photo ID', sub: 'National ID card (NIN)', icon: Icons.badge_rounded),
      (title: 'Live selfie check', sub: 'Biometric photo match', icon: Icons.face_retouching_natural_rounded),
      (title: 'Proof of address', sub: 'Utility bill (electricity or water)', icon: Icons.home_work_rounded),
      (title: 'Licence and vehicle', sub: 'Class B licence · Plate LA-492-IKJ', icon: Icons.drive_eta_rounded),
      (title: 'Police clearance', sub: 'Criminal record check', icon: Icons.verified_user_rounded),
      (title: 'Guarantor details', sub: 'Next of kin and guarantor', icon: Icons.people_alt_rounded),
    ];
    final v = widget.isVerified;
    final done = v ? docs.length : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _st(0, .35, _pageHeader('Onboarding', 'Verification')),
        const SizedBox(height: 20),
        _st(
          .1,
          .55,
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: v ? _C.gradient : _C.dark,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (v ? _C.lime : Colors.black).withValues(alpha: .3),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: done / docs.length),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (_, p, __) => CircularProgressIndicator(
                            value: p,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                            (v ? _C.ink : Colors.white).withValues(alpha: .15),
                            color: v ? _C.ink : _C.lime,
                          ),
                        ),
                      ),
                      Text('$done/${docs.length}',
                          style: TextStyle(
                              color: v ? _C.ink : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v ? 'You are verified' : 'Under review',
                          style: TextStyle(
                              color: v ? _C.ink : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.3)),
                      const SizedBox(height: 4),
                      Text(
                          v
                              ? 'All documents approved. You can accept any delivery.'
                              : 'Reviews usually take up to 24 hours. We will notify you.',
                          style: TextStyle(
                              color: (v ? _C.ink : Colors.white)
                                  .withValues(alpha: .7),
                              fontSize: 12.5,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < docs.length; i++)
          _Stagger(
            anim: _enter,
            begin: .25 + .07 * i,
            end: .65 + .06 * i,
            dx: 36,
            dy: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _card(20),
                child: Row(
                  children: [
                    _IconBox(
                        icon: docs[i].icon,
                        bg: _C.lime.withValues(alpha: .5),
                        color: _C.ink,
                        size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(docs[i].title,
                              style: const TextStyle(
                                  color: _C.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(docs[i].sub,
                              style: const TextStyle(
                                  color: _C.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      v ? 'Verified' : 'In review',
                      bg: v ? _C.greenBg : _C.amberBg,
                      fg: v ? _C.green : _C.amber,
                      icon: v ? Icons.check_rounded : Icons.hourglass_bottom_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------- Health tab
  Widget _healthPage() {
    final stepsP = (_steps / 10000).clamp(0.0, 1.0);
    final waterP = (_water / 2.5).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _st(
          0,
          .35,
          _pageHeader(
            'Stay safe on the road',
            'Health',
            trailing: _Pressable(
              onTap: () => _push(HealthDashboardScreen(
                  isCourierMode: true, userName: widget.driverName)),
              child: _pill('Full view',
                  bg: _C.ink, fg: _C.lime, icon: Icons.open_in_new_rounded),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _st(.1, .55, _restCard()),
        const SizedBox(height: 14),
        _st(
          .2,
          .65,
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.directions_walk_rounded,
                  value: '$_steps',
                  label: 'Steps walked',
                  progress: stepsP,
                  note: 'Goal 10,000',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _MetricCard(
                  icon: Icons.local_fire_department_rounded,
                  value: '520 kcal',
                  label: 'Active calories',
                  progress: .52,
                  note: 'Parcel handling',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _st(
          .3,
          .75,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _card(24),
            child: Column(
              children: [
                Row(
                  children: [
                    const _IconBox(
                        icon: Icons.water_drop_rounded,
                        bg: Color(0xFFDDF1FB),
                        color: Color(0xFF0B6FA4),
                        size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shift hydration',
                              style: TextStyle(
                                  color: _C.ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text('${_water.toStringAsFixed(2)} L of 2.5 L today',
                              style: const TextStyle(
                                  color: _C.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    _Pressable(
                      onTap: () {
                        if (_water >= 2.5) {
                          _snack('Daily water goal reached. Well done!');
                          return;
                        }
                        HapticFeedback.selectionClick();
                        setState(() => _water = math.min(2.5, _water + .25));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _C.ink,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('+250 ml',
                            style: TextStyle(
                                color: _C.lime,
                                fontWeight: FontWeight.w900,
                                fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: waterP,
                    minHeight: 8,
                    backgroundColor: Colors.black.withValues(alpha: .08),
                    color: const Color(0xFF2B9BD6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        _st(.4, .8, _sectionTitle('Lifting and posture')),
        const SizedBox(height: 12),
        _st(
          .45,
          .9,
          Container(
            decoration: _card(24),
            child: const Column(
              children: [
                _TipTile(
                  icon: Icons.accessibility_new_rounded,
                  title: 'Bend your knees, not your back',
                  sub: 'Squat down to lift heavy boxes from the ground.',
                ),
                _TipDivider(),
                _TipTile(
                  icon: Icons.center_focus_strong_rounded,
                  title: 'Keep the load close to your chest',
                  sub: 'Cuts strain on your lower back.',
                ),
                _TipDivider(),
                _TipTile(
                  icon: Icons.fitness_center_rounded,
                  title: 'Maximum 25 kg per lift',
                  sub: 'Use a trolley or ask for help with heavier parcels.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _restCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _darkCard(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(
                icon: _rest ? Icons.coffee_rounded : Icons.timer_rounded,
                bg: _C.lime,
                color: _C.ink,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_rest ? 'REST BREAK ACTIVE' : 'ACTIVE SHIFT',
                        style: const TextStyle(
                            color: _C.lime,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 3),
                    Text(
                        _rest
                            ? 'Requests paused. Stretch and hydrate.'
                            : '4 h 20 min riding today',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.25)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _rest ? 1 : .72,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: _C.lime,
            ),
          ),
          const SizedBox(height: 6),
          Text(_rest ? 'Break in progress' : 'Take a break after 6 hours',
              style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
          const SizedBox(height: 16),
          _Pressable(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _rest = !_rest);
              _snack(_rest
                  ? 'Rest break started. Requests are paused.'
                  : 'Welcome back! You can receive requests again.');
            },
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _rest ? _C.lime : Colors.white12,
                borderRadius: BorderRadius.circular(16),
                border: _rest ? null : Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _rest
                          ? Icons.play_arrow_rounded
                          : Icons.pause_circle_outline_rounded,
                      color: _rest ? _C.ink : Colors.white),
                  const SizedBox(width: 8),
                  Text(_rest ? 'Resume deliveries' : 'Take a 15 min break',
                      style: TextStyle(
                          color: _rest ? _C.ink : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- Profile tab
  Widget _profilePage() {
    final v = widget.isVerified;

    Widget tile(IconData icon, String title, String sub, VoidCallback onTap) =>
        _Pressable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _IconBox(
                    icon: icon,
                    bg: _C.lime.withValues(alpha: .5),
                    color: _C.ink,
                    size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: _C.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(sub,
                          style:
                          const TextStyle(color: _C.muted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _C.muted),
              ],
            ),
          ),
        );

    Widget group(List<Widget> tiles) => Container(
      decoration: _card(24),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.black.withValues(alpha: .06)),
            tiles[i],
          ],
        ],
      ),
    );

    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(t,
          style: const TextStyle(
              color: Colors.black45,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5)),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _st(0, .35, _pageHeader('Your profile', 'Account')),
        const SizedBox(height: 20),
        _st(
          .1,
          .55,
          AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final a = _loop.value * 2 * math.pi;
              return Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(22),
                decoration: _darkCard(30),
                child: Stack(
                  children: [
                    Positioned(
                      top: -70 + 12 * math.sin(a),
                      right: -60 + 12 * math.cos(a),
                      child: _glow(220, .4),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _C.lime,
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.lime.withValues(alpha: .5),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: _C.ink,
                                child: Text(_initials,
                                    style: const TextStyle(
                                        color: _C.lime,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                        widget.email.isEmpty
                                            ? 'driver@sekuredelivery.com'
                                            : widget.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13)),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _C.lime.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: _C.lime.withValues(alpha: .5)),
                                    ),
                                    child: Text(
                                        v ? 'VERIFIED COURIER' : 'VERIFICATION PENDING',
                                        style: const TextStyle(
                                            color: _C.lime,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 18),
                          height: 1,
                          color: Colors.white.withValues(alpha: .12),
                        ),
                        Row(
                          children: [
                            _ProfileStat(value: '$_trips', label: 'Trips today'),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: .12)),
                            const _ProfileStat(value: '4.9', label: 'Rating'),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: .12)),
                            const _ProfileStat(value: 'Dec 2024', label: 'Rider since'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        _st(.3, .7, label('ACCOUNT')),
        const SizedBox(height: 10),
        _st(
          .34,
          .78,
          group([
            tile(Icons.two_wheeler_rounded, 'Vehicle information',
                'Honda Ace 125 · LA-492-IKJ',
                    () => _snack('Vehicle details are up to date.')),
            tile(Icons.account_balance_rounded, 'Bank and payout settings',
                'First Bank of Nigeria · •••• 4018',
                    () => _snack('Manage payout account')),
            tile(Icons.alarm_rounded, 'Delivery reminders',
                'Shift and pickup alerts',
                    () => _push(const EventReminderScreen())),
          ]),
        ),
        const SizedBox(height: 26),
        _st(.44, .85, label('SUPPORT')),
        const SizedBox(height: 10),
        _st(
          .48,
          .9,
          group([
            tile(Icons.support_agent_rounded, 'Driver support 24/7',
                'Live chat and incident reporting',
                    () => _push(const SupportChatScreen(isCourierSupport: true))),
            tile(Icons.psychology_rounded, 'Sekure AI Copilot',
                'Routes, pricing and tips',
                    () => _push(const AiAssistantScreen(isCourierMode: true))),
          ]),
        ),
        const SizedBox(height: 24),
        _st(.6, 1, _signOutButton()),
        const SizedBox(height: 14),
        _st(
          .7,
          1,
          const Center(
            child: Text('Sekure Driver app · Version 1.0.0',
                style: TextStyle(color: _C.muted, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _signOutButton() => _Pressable(
    onTap: _confirmSignOut,
    child: Container(
      height: 54,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3B8B8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout_rounded, color: _C.red, size: 20),
          SizedBox(width: 8),
          Text('Sign out',
              style: TextStyle(
                  color: _C.red, fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    ),
  );

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration:
                const BoxDecoration(color: _C.lime, shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: _C.ink, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Sign out?',
                  style: TextStyle(
                      color: _C.ink, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                  _active != null
                      ? 'You have an active delivery. It stays assigned to you.'
                      : 'You will need to log in again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _C.muted, fontSize: 13.5)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.ink,
                    foregroundColor: _C.lime,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('STAY SIGNED IN',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: .8)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sign out',
                    style: TextStyle(
                        color: _C.red, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
            (_) => false,
      );
    }
  }
}

// ------------------------------------------------------------ Bottom sheets
class _CashoutSheet extends StatefulWidget {
  final double balance;
  const _CashoutSheet({required this.balance});

  @override
  State<_CashoutSheet> createState() => _CashoutSheetState();
}

class _CashoutSheetState extends State<_CashoutSheet> {
  static const _min = 1000;
  late final TextEditingController _ctrl =
  TextEditingController(text: widget.balance.round().toString());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_ctrl.text) ?? 0;

  String? get _error {
    if (_amount == 0) return null;
    if (_amount < _min) return 'Minimum withdrawal is ${_naira(_min)}';
    if (_amount > widget.balance) return 'That is more than your balance';
    return null;
  }

  bool get _valid => _amount >= _min && _amount <= widget.balance;

  @override
  Widget build(BuildContext context) {
    final quick = <int>[
      for (final v in [10000, 20000]) if (v < widget.balance) v,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Withdraw to bank',
                style: TextStyle(
                    color: _C.ink, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Available: ${_naira(widget.balance)}',
                style: const TextStyle(color: _C.muted, fontSize: 13)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  _IconBox(
                      icon: Icons.account_balance_rounded,
                      bg: _C.lime,
                      color: _C.ink,
                      size: 44),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Bank of Nigeria',
                            style: TextStyle(
                                color: _C.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w900)),
                        Text('•••• 4018 · Instant payout',
                            style: TextStyle(color: _C.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₦ ',
                prefixStyle: const TextStyle(
                    color: _C.ink, fontWeight: FontWeight.w900, fontSize: 20),
                errorText: _error,
                filled: true,
                fillColor: _C.bg,
                floatingLabelStyle:
                const TextStyle(color: _C.ink, fontWeight: FontWeight.w800),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  BorderSide(color: Colors.black.withValues(alpha: .08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _C.ink, width: 1.6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _C.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _C.red, width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                for (final v in quick)
                  ActionChip(
                    label: Text(_naira(v)),
                    backgroundColor: _C.bg,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(
                        color: _C.ink, fontWeight: FontWeight.w800, fontSize: 12.5),
                    onPressed: () => _ctrl.text = '$v',
                  ),
                ActionChip(
                  label: const Text('All'),
                  backgroundColor: _C.lime.withValues(alpha: .6),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                      color: _C.ink, fontWeight: FontWeight.w900, fontSize: 12.5),
                  onPressed: () => _ctrl.text = widget.balance.round().toString(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.ink,
                  foregroundColor: _C.lime,
                  disabledBackgroundColor: Colors.black12,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _valid ? () => Navigator.pop(context, _amount) : null,
                child: Text(
                  _valid ? 'WITHDRAW ${_naira(_amount)}' : 'ENTER AN AMOUNT',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: .8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Widgets
class _Stagger extends StatelessWidget {
  final Animation<double> anim;
  final double begin, end, dx, dy;
  final Widget child;
  const _Stagger({
    required this.anim,
    required this.begin,
    required this.end,
    this.dx = 0,
    this.dy = 24,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curve =
    Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic);
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
      scale: _down ? .96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg, color;
  final double size;
  const _IconBox(
      {required this.icon,
        required this.bg,
        required this.color,
        this.size = 36});

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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color subColor;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _card(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _IconBox(icon: icon, bg: _C.lime, color: _C.ink, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _C.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: const TextStyle(
                  color: _C.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3)),
        ),
        const SizedBox(height: 4),
        Text(sub,
            style: TextStyle(
                color: subColor, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value, label, note;
  final double progress;
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.progress,
    required this.note,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _card(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: icon, bg: _C.lime, color: _C.ink, size: 38),
        const SizedBox(height: 14),
        Text(value,
            style: const TextStyle(
                color: _C.ink, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: _C.muted, fontSize: 12)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: Colors.black.withValues(alpha: .08),
              color: _C.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(note,
            style: const TextStyle(
                color: _C.muted, fontSize: 10.5, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _TipTile({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        _IconBox(
            icon: icon,
            bg: _C.lime.withValues(alpha: .5),
            color: _C.ink,
            size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _C.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      color: _C.muted, fontSize: 12, height: 1.3)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TipDivider extends StatelessWidget {
  const _TipDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Colors.black.withValues(alpha: .06));
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
      ],
    ),
  );
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  Widget _item(int i, IconData off, IconData on, String label) {
    final sel = current == i;
    return Semantics(
      button: true,
      selected: sel,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding:
          EdgeInsets.symmetric(horizontal: sel ? 14 : 10, vertical: 10),
          decoration: BoxDecoration(
            color: sel ? _C.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: sel ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(sel ? on : off,
                    size: 23, color: sel ? _C.lime : _C.muted),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: sel
                    ? Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _C.lime)),
                )
                    : const SizedBox(width: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(0, Icons.two_wheeler_outlined, Icons.two_wheeler_rounded,
                  'Rides'),
              _item(1, Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet_rounded, 'Wallet'),
              _item(2, Icons.verified_user_outlined,
                  Icons.verified_user_rounded, 'Verify'),
              _item(3, Icons.favorite_border_rounded, Icons.favorite_rounded,
                  'Health'),
              _item(4, Icons.person_outline_rounded, Icons.person_rounded,
                  'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}