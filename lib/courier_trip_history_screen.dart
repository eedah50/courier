import 'package:flutter/material.dart';
import 'theme.dart';

class CourierTripHistoryScreen extends StatelessWidget {
  const CourierTripHistoryScreen({super.key});

  final List<Map<String, dynamic>> _trips = const [
    {'id': 'SKR-WAY-8842', 'address': '45 Victoria Island, Lagos', 'time': 'Today, 11:30 AM', 'payout': '₦4,500', 'dist': '6.4 km'},
    {'id': 'SKR-WAY-8839', 'address': '18 Maryland Estate, Lagos', 'time': 'Yesterday, 4:15 PM', 'payout': '₦3,800', 'dist': '4.2 km'},
    {'id': 'SKR-WAY-8810', 'address': 'Lekki Phase 1 Gate 2', 'time': '16 Jan, 2:00 PM', 'payout': '₦5,200', 'dist': '8.1 km'},
  ];

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
        title: const Text('Driver Trip History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121216),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF26262C)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, color: AppColors.yellow, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${trip['id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                          Text(trip['payout'] as String, style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(trip['address'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                      const SizedBox(height: 2),
                      Text('${trip['time']} • ${trip['dist']}', style: const TextStyle(color: Colors.white38, fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
