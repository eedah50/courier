import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class PromoReferralScreen extends StatefulWidget {
  const PromoReferralScreen({super.key});

  @override
  State<PromoReferralScreen> createState() => _PromoReferralScreenState();
}

class _PromoReferralScreenState extends State<PromoReferralScreen> {
  final _promoCodeController = TextEditingController();

  final List<Map<String, dynamic>> _promos = [
    {
      'code': 'SKR50',
      'title': '50% OFF Express Delivery',
      'expiry': 'Valid till end of month',
      'desc': 'Applies to any express package delivery within Lagos & Abuja.',
    },
    {
      'code': 'FREEDEL',
      'title': 'Free Interstate Delivery',
      'expiry': 'Valid on your next 2 orders',
      'desc': 'Enjoy zero delivery fees on interstate cargo and document waybills.',
    },
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)), backgroundColor: AppColors.black, behavior: SnackBarBehavior.floating));
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Promo Codes & Referrals', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Code Input Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Have a Promo Code?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.black)),
                  const SizedBox(height: 6),
                  const Text('Enter your code below to instantly apply discounts to your waybills.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'e.g. SKR50',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.yellow,
                          minimumSize: const Size(100, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (_promoCodeController.text.trim().isEmpty) {
                            _toast('Please enter a promo code');
                            return;
                          }
                          _toast('Promo code "${_promoCodeController.text.toUpperCase()}" applied successfully!');
                          _promoCodeController.clear();
                        },
                        child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Available Promos
            const Text('Available Promos & Vouchers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.black)),
            const SizedBox(height: 12),
            ..._promos.map((promo) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(promo['code'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
                          child: Text(promo['expiry'] as String, style: const TextStyle(color: AppColors.yellow, fontSize: 10.5, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(promo['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.black)),
                    const SizedBox(height: 4),
                    Text(promo['desc'] as String, style: TextStyle(color: AppColors.black.withValues(alpha: 0.8), fontSize: 12.5)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Referral Program Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard_rounded, color: AppColors.orange, size: 28),
                      SizedBox(width: 10),
                      Text('Invite Friends & Earn ₦1,500', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Share your unique referral code with friends. When they complete their first waybill, you both get ₦1,500 credited to your wallet!', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SEKURE-AMARA-88', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: 'SEKURE-AMARA-88'));
                            _toast('Referral code copied to clipboard!');
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.orange),
                          label: const Text('COPY', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.orange)),
                        ),
                      ],
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
