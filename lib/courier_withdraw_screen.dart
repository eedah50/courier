import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class CourierWithdrawScreen extends StatefulWidget {
  const CourierWithdrawScreen({super.key});

  @override
  State<CourierWithdrawScreen> createState() => _CourierWithdrawScreenState();
}

class _CourierWithdrawScreenState extends State<CourierWithdrawScreen> {
  double _balance = 48500.0;
  bool _loading = false;

  final List<Map<String, dynamic>> _payoutHistory = [
    {'title': 'Bank Withdrawal (First Bank)', 'date': 'Yesterday, 10:00 AM', 'amount': '-₦30,000.00', 'status': 'Successful'},
    {'title': 'Bank Withdrawal (First Bank)', 'date': '12 Jan, 4:15 PM', 'amount': '-₦25,000.00', 'status': 'Successful'},
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.yellow,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _showWithdrawModal() {
    final amtCtrl = TextEditingController(text: '20000');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141418),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Instant Bank Payout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Transfer earnings directly to your verified First Bank account.', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                labelText: 'Amount (₦)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E22),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2C2C32))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2C2C32))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.yellow, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                double wAmount = double.tryParse(amtCtrl.text) ?? 10000.0;
                if (wAmount > _balance) {
                  _toast('Insufficient available balance.');
                  return;
                }
                setState(() {
                  _balance -= wAmount;
                  _payoutHistory.insert(0, {
                    'title': 'Bank Withdrawal (First Bank)',
                    'date': 'Just now',
                    'amount': '-₦${wAmount.toStringAsFixed(2)}',
                    'status': 'Successful',
                  });
                });
                Navigator.pop(ctx);
                _toast('Payout of ₦${wAmount.toStringAsFixed(0)} initiated successfully!');
              },
              child: const Text('CONFIRM INSTANT PAYOUT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
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
        title: const Text('Withdrawal & Payouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF121216),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Payout Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('₦${_balance.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.yellow, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _showWithdrawModal,
                    child: const Text('WITHDRAW TO BANK ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bank Account Details Tile
            const Text('Primary Payout Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121216),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF26262C)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: AppColors.yellow, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Bank of Nigeria', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('3082••••9012 • Ibrahim Olatunji', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Payout History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),

            ..._payoutHistory.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121216),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26262C)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text(item['date'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    Text(item['amount'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
