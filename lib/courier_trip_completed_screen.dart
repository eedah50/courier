import 'package:flutter/material.dart';
import 'theme.dart';

class CourierTripCompletedScreen extends StatelessWidget {
  final String orderId;
  final int payout;

  const CourierTripCompletedScreen({
    super.key,
    required this.orderId,
    required this.payout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success Badge
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.yellow, blurRadius: 25, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.black, size: 54),
              ),
              const SizedBox(height: 24),
              const Text(
                'Trip Completed Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Order #$orderId is delivered. Payout credited to your wallet.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Earnings Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121216),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF26262C)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Base Fare', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                        Text('₦${(payout * 0.8).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Distance Bonus', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                        Text('₦${(payout * 0.2).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Customer Tip', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                        Text('₦500', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(color: Color(0xFF26262C), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Earned', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('₦${payout + 500}', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 22)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Return to Console Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context); // return to courier dashboard
                },
                child: const Text('BACK TO COURIER DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
