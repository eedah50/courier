import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 24500.00;

  final List<Map<String, dynamic>> _transactions = [
    {'title': 'Waybill Payment #SKR-WAY-8842', 'date': 'Today, 2:45 PM', 'amount': '-₦4,850.00', 'isCredit': false},
    {'title': 'Wallet Top Up via Visa 4921', 'date': 'Yesterday', 'amount': '+₦20,000.00', 'isCredit': true},
    {'title': 'Waybill Payment #SKR-WAY-7930', 'date': '3 days ago', 'amount': '-₦7,500.00', 'isCredit': false},
    {'title': 'Referral Bonus Reward', 'date': '5 days ago', 'amount': '+₦1,500.00', 'isCredit': true},
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)), backgroundColor: AppColors.black, behavior: SnackBarBehavior.floating));
  }

  void _showTopUpModal() {
    final amtCtrl = TextEditingController(text: '10000');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Up Sekure Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Amount (₦)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lemon,
                foregroundColor: AppColors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                double added = double.tryParse(amtCtrl.text) ?? 5000.0;
                setState(() {
                  _balance += added;
                  _transactions.insert(0, {
                    'title': 'Wallet Top Up via Card',
                    'date': 'Just now',
                    'amount': '+₦${added.toStringAsFixed(0)}',
                    'isCredit': true,
                  });
                });
                Navigator.pop(ctx);
                _toast('Wallet successfully credited!');
              },
              child: const Text('CONFIRM TOP UP', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Sekure Digital Wallet', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.orange.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Balance', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                      Icon(Icons.account_balance_wallet_rounded, color: AppColors.black),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.black),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: AppColors.yellow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: _showTopUpModal,
                          child: const Text('TOP UP', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.black,
                            side: const BorderSide(color: AppColors.black, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: () => _toast('Withdrawal feature enabled for verified bank accounts.'),
                          child: const Text('WITHDRAW', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Transaction History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.black)),
            const SizedBox(height: 12),

            ..._transactions.map((tx) {
              final isCredit = tx['isCredit'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
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
                          Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          const SizedBox(height: 2),
                          Text(tx['date'] as String, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      tx['amount'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isCredit ? const Color(0xFF2E7D32) : AppColors.black,
                      ),
                    ),
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
