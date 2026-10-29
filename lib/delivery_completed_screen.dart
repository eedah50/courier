import 'package:flutter/material.dart';
import 'theme.dart';

class DeliveryCompletedScreen extends StatefulWidget {
  final String waybillId;
  final String courierName;

  const DeliveryCompletedScreen({
    super.key,
    required this.waybillId,
    required this.courierName,
  });

  @override
  State<DeliveryCompletedScreen> createState() => _DeliveryCompletedScreenState();
}

class _DeliveryCompletedScreenState extends State<DeliveryCompletedScreen> {
  int _rating = 5;
  int _selectedTipIndex = 1; // ₦500
  final List<int> _tipAmounts = [200, 500, 1000, 2000];
  final _reviewController = TextEditingController();

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Delivery Completed', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.lemon,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all_rounded, color: AppColors.black, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Package Delivered Successfully!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Waybill ${widget.waybillId} was delivered by ${widget.courierName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Proof of Delivery Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.photo_camera_rounded, color: AppColors.orange, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Proof of Delivery Verified', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Recipient signature & doorstep photo captured.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating Stars
            const Text('Rate your Delivery Experience', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  icon: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 38,
                  ),
                  onPressed: () => setState(() => _rating = star),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Tip Driver Section
            const Text('Tip Your Courier', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('100% of your tip goes directly to the driver.', style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _tipAmounts.asMap().entries.map((entry) {
                final idx = entry.key;
                final amt = entry.value;
                final selected = _selectedTipIndex == idx;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTipIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.black : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? AppColors.black : Colors.black12),
                      ),
                      child: Text(
                        '₦$amt',
                        style: TextStyle(
                          color: selected ? AppColors.yellow : AppColors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Review TextField
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a compliment or review for ${widget.courierName}...',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.yellow,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                _toast('Thank you! Rating & tip submitted successfully.');
                Navigator.pop(context); // return to dashboard
              },
              child: const Text('SUBMIT FEEDBACK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
