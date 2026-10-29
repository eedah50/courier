import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'theme.dart';

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

class _Highlight {
  final IconData icon;
  final String value;
  final String label;
  const _Highlight(this.icon, this.value, this.label);
}

const _courierSections = [
  _Section(
    'Courier Independent Partner Status',
    'As a courier driver partner on Sekure Delivery, you operate as an independent logistics contractor. You are responsible for maintaining valid personal vehicle licensing, safety gear, and local transport compliance.',
  ),
  _Section(
    'Platform Commission & Earnings Payouts',
    'Sekure Delivery retains a standard 20% platform service fee from completed waybill fares. Net earnings are deposited directly to your driver wallet and can be cashed out instantly to your verified bank account.',
  ),
  _Section(
    'Verification & Compliance Requirements',
    'Couriers must successfully pass the 5-step verification process: Government Photo ID (NIN/Passport), Biometric Live Selfie Liveness Check, Proof of Residence, Vehicle Inspection Certificate, and Police Clearance with Guarantor details.',
  ),
  _Section(
    'Safety Ratings & Code of Conduct',
    'Couriers agree to handle all customer shipments with care and professionalism. Maintaining an average rating above 4.2★ is required to remain active on the Sekure Delivery dispatch network.',
  ),
  _Section(
    'Real-Time Location Tracking',
    'Couriers consent to sharing real-time GPS location data during active delivery assignments to allow shippers and recipients to monitor parcel progress.',
  ),
];

const _customerSections = [
  _Section(
    'Customer Terms of Service',
    'By using Sekure Delivery, you agree to provide accurate pickup and dropoff addresses and valid contact details. Illegal goods, hazardous materials, and prohibited contraband are strictly forbidden on the platform.',
  ),
  _Section(
    'Waybill Dispatch & Doorstep Handover',
    'Packages must be securely sealed prior to courier arrival. Couriers conduct direct hand-to-hand delivery to the designated recipient or doorstep per your order instructions.',
  ),
  _Section(
    'Transparent Pricing, Insurance & Refunds',
    'All waybill charges are calculated transparently based on distance, package weight, and service tier (Standard vs Express). Optional waybill insurance covers declared item value against loss or damage.',
  ),
  _Section(
    'Customer Privacy & Data Protection',
    'Your personal information, recipient phone numbers, and delivery addresses are encrypted using SSL/TLS protocols and strictly used for order fulfillment and live tracking.',
  ),
];

const _courierHighlights = [
  _Highlight(Icons.payments_outlined, '20%', 'Platform fee'),
  _Highlight(Icons.star_rounded, '4.2★', 'Min. rating'),
  _Highlight(Icons.verified_user_outlined, '5-step', 'Verification'),
];

const _customerHighlights = [
  _Highlight(Icons.lock_outline_rounded, 'SSL/TLS', 'Data encrypted'),
  _Highlight(Icons.pan_tool_alt_outlined, 'Doorstep', 'Hand-to-hand'),
  _Highlight(Icons.shield_outlined, 'Insured', 'Optional cover'),
];

class TermsPrivacyScreen extends StatefulWidget {
  final bool isCourierAgreement;
  final bool isFirstTimeOnboarding;

  const TermsPrivacyScreen({
    super.key,
    this.isCourierAgreement = false,
    this.isFirstTimeOnboarding = false,
  });

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateProgress());
  }

  void _updateProgress() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max <= 0 ? 1 : (_scroll.offset / max).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (widget.isFirstTimeOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Header: black hero with lemon glow, title, version chips, reading progress
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    final courier = widget.isCourierAgreement;
    final onboarding = widget.isFirstTimeOnboarding;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Soft lemon glows
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
                    AppColors.lemon.withValues(alpha: 0.38),
                    AppColors.lemon.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
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
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: back button + document label
                  Row(
                    children: [
                      if (!onboarding)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 40),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.lemon.withValues(alpha: 0.55),
                          ),
                          color: AppColors.lemon.withValues(alpha: 0.10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.gavel_rounded,
                                color: AppColors.lemon, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              courier
                                  ? 'DRIVER PARTNER AGREEMENT'
                                  : 'USER TERMS & PRIVACY POLICY',
                              style: const TextStyle(
                                color: AppColors.lemon,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Icon badge + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.lemon, AppColors.yellow],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lemon.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courier
                                  ? 'Courier Partner\nAgreement'
                                  : 'Terms of Service\n& Privacy Policy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    courier
                        ? 'Sekure Delivery Courier Partner Agreement'
                        : 'Sekure Delivery Customer Terms of Service',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MetaChip(icon: Icons.update_rounded, text: 'October 2026'),
                      _MetaChip(icon: Icons.tag_rounded, text: 'Version 1.0'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Reading progress
                  ValueListenableBuilder<double>(
                    valueListenable: _progress,
                    builder: (context, value, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.lemon,
                                            AppColors.yellow,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(value * 100).round()}% read',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
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
  // Bottom action bar (sticky): consent checkbox (onboarding) + CTA
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar() {
    final onboarding = widget.isFirstTimeOnboarding;
    final canContinue = !onboarding || _accepted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onboarding) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _accepted = !_accepted),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _accepted ? AppColors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accepted ? AppColors.black : Colors.black26,
                          width: 1.6,
                        ),
                      ),
                      child: AnimatedScale(
                        scale: _accepted ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.lemon,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I have read and agree to the Terms of Service and Privacy Policy.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.lemon,
                  disabledBackgroundColor: Colors.black12,
                  disabledForegroundColor: Colors.black38,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: canContinue ? _onContinue : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      onboarding ? 'I AGREE & CONTINUE' : 'I AGREE & UNDERSTAND',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courier = widget.isCourierAgreement;
    final sections = courier ? _courierSections : _customerSections;
    final highlights = courier ? _courierHighlights : _customerHighlights;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                // Key points at a glance
                Row(
                  children: [
                    for (var i = 0; i < highlights.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: _HighlightCard(highlight: highlights[i])),
                    ],
                  ],
                ),

                const SizedBox(height: 22),

                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'THE DETAILS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      color: Colors.black45,
                    ),
                  ),
                ),

                for (var i = 0; i < sections.length; i++)
                  _SectionCard(index: i, section: sections[i]),

                const SizedBox(height: 4),

                // Closing note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lemon.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.lemon.withValues(alpha: 0.7),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.black, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'By continuing, you confirm that you have read and understood these terms.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small glass chip used in the header (date / version)
// -----------------------------------------------------------------------------
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// "At a glance" key-point card
// -----------------------------------------------------------------------------
class _HighlightCard extends StatelessWidget {
  final _Highlight highlight;

  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lemon,
            ),
            child: Icon(highlight.icon, color: AppColors.black, size: 20),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              highlight.value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            highlight.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Numbered section card with staggered entrance
// -----------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final int index;
  final _Section section;

  const _SectionCard({required this.index, required this.section});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.lemon,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // short lemon accent underline
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.lemon,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.body,
                    style: const TextStyle(
                      fontSize: 12.8,
                      color: Colors.black87,
                      height: 1.55,
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