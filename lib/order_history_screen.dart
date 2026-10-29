import 'package:flutter/material.dart';
import 'theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'SKR-WAY-8842',
      'recipient': 'Dr. Aliyu Mohammed',
      'address': 'Plot 241, Central Business District, Abuja',
      'status': 'Delivered',
      'date': 'Today, 2:45 PM',
      'amount': '₦4,850.00',
      'category': 'Documents & Legal',
    },
    {
      'id': 'SKR-WAY-8819',
      'recipient': 'Chidinma Nnamdi',
      'address': '14 Admiralty Way, Lekki Phase 1, Lagos',
      'status': 'In Transit',
      'date': 'Today, 11:20 AM',
      'amount': '₦3,200.00',
      'category': 'Gadgets & Electronics',
    },
    {
      'id': 'SKR-WAY-7930',
      'recipient': 'Oluwaseun Balogun',
      'address': '8 Bodija Layout, Ibadan',
      'status': 'Delivered',
      'date': 'Yesterday',
      'amount': '₦7,500.00',
      'category': 'Fragile & Gifts',
    },
    {
      'id': 'SKR-WAY-7104',
      'recipient': 'Fatima Bello',
      'address': '5 Ibrahim Taiwo Road, Kano',
      'status': 'Cancelled',
      'date': '3 days ago',
      'amount': '₦12,400.00',
      'category': 'Cargo & Heavy',
    },
  ];

  void _showReceiptModal(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Waybill Receipt & Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Waybill ID:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                Text(order['status'] as String, style: TextStyle(fontWeight: FontWeight.w900, color: order['status'] == 'Delivered' ? const Color(0xFF2E7D32) : AppColors.orange)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Category:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                Text(order['category'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recipient:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                Text(order['recipient'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Address:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Text(order['address'] as String, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Fare Paid:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text(order['amount'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.yellow,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt downloaded as PDF successfully!')));
              },
              child: const Text('DOWNLOAD OFFICIAL RECEIPT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? _orders
        : _orders.where((o) => o['status'] == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order History & Receipts', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: ['All', 'In Transit', 'Delivered', 'Cancelled'].map((cat) {
                final selected = _filter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: AppColors.black,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.yellow : AppColors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (val) => setState(() => _filter = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final order = filtered[index];
                final isDelivered = order['status'] == 'Delivered';
                final isInTransit = order['status'] == 'In Transit';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () => _showReceiptModal(order),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDelivered ? const Color(0xFFE8F5E9) : isInTransit ? const Color(0xFFFFFBEB) : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDelivered ? Icons.check_circle_rounded : isInTransit ? Icons.local_shipping_rounded : Icons.cancel_rounded,
                        color: isDelivered ? const Color(0xFF2E7D32) : isInTransit ? AppColors.orange : Colors.red,
                        size: 24,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        Text(order['amount'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.orange)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('To: ${order['recipient']}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.black, fontSize: 12.5)),
                        const SizedBox(height: 2),
                        Text(order['date'] as String, style: const TextStyle(color: Colors.black54, fontSize: 11.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
