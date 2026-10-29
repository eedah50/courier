import 'package:flutter/material.dart';
import 'theme.dart';

class CourierRatingsScreen extends StatelessWidget {
  const CourierRatingsScreen({super.key});

  final List<Map<String, dynamic>> _reviews = const [
    {'name': 'Amara Okafor', 'rating': 5.0, 'comment': 'Extremely polite courier! Delivered fragile electronics in perfect condition ahead of schedule.', 'date': 'Today'},
    {'name': 'Dr. Aliyu Mohammed', 'rating': 5.0, 'comment': 'Great communication and very fast delivery.', 'date': 'Yesterday'},
    {'name': 'Chidinma Nnamdi', 'rating': 4.8, 'comment': 'Careful handling of documents. Thank you!', 'date': '3 days ago'},
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
        title: const Text('Ratings & Customer Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Rating Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF121216),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Text('4.9', style: TextStyle(color: AppColors.yellow, fontSize: 38, fontWeight: FontWeight.w900)),
                      Row(
                        children: List.generate(5, (_) => const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16)),
                      ),
                      const SizedBox(height: 4),
                      const Text('314 Ratings', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricBar(label: 'Punctuality', score: '98%'),
                        SizedBox(height: 8),
                        _MetricBar(label: 'Care & Handling', score: '99%'),
                        SizedBox(height: 8),
                        _MetricBar(label: 'Communication', score: '97%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Recent Customer Reviews', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),

            ..._reviews.map((rev) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121216),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26262C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rev['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
                            const SizedBox(width: 2),
                            Text('${rev['rating']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(rev['comment'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3)),
                    const SizedBox(height: 6),
                    Text(rev['date'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11)),
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

class _MetricBar extends StatelessWidget {
  final String label;
  final String score;

  const _MetricBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
        Text(score, style: const TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
