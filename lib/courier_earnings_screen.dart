import 'package:flutter/material.dart';
import 'theme.dart';

class CourierEarningsScreen extends StatefulWidget {
  const CourierEarningsScreen({super.key});

  @override
  State<CourierEarningsScreen> createState() => _CourierEarningsScreenState();
}

class _CourierEarningsScreenState extends State<CourierEarningsScreen> {
  String _period = 'This Week';

  final List<Map<String, dynamic>> _dailyBreakdown = [
    {'day': 'Mon', 'amount': '₦8,500', 'trips': 3},
    {'day': 'Tue', 'amount': '₦12,200', 'trips': 4},
    {'day': 'Wed', 'amount': '₦9,800', 'trips': 3},
    {'day': 'Thu', 'amount': '₦18,000', 'trips': 4},
    {'day': 'Fri', 'amount': '₦14,500', 'trips': 5},
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
        title: const Text('Driver Earnings & Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Toggle
            Row(
              children: ['Today', 'This Week', 'This Month'].map((p) {
                final selected = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    selectedColor: AppColors.yellow,
                    backgroundColor: const Color(0xFF1E1E22),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (val) => setState(() => _period = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF121216),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.yellow.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Net Earnings', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('₦63,000.00', style: TextStyle(color: AppColors.yellow, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBox(title: 'Completed Trips', value: '19 Trips'),
                      _StatBox(title: 'Total Hours', value: '28.5 hrs'),
                      _StatBox(title: 'Customer Tips', value: '₦4,500'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Daily Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),

            ..._dailyBreakdown.map((item) {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler_rounded, color: AppColors.yellow, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['day'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('${item['trips']} trips completed', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      item['amount'] as String,
                      style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 15),
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

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),
      ],
    );
  }
}
