import 'package:flutter/material.dart';
import 'theme.dart';

class EventReminderScreen extends StatefulWidget {
  const EventReminderScreen({super.key});

  @override
  State<EventReminderScreen> createState() => _EventReminderScreenState();
}

class _EventReminderScreenState extends State<EventReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Birthday Gift Delivery to Amara',
      'category': 'Gift & Celebration',
      'date': 'Tomorrow, 10:00 AM',
      'location': '45 Victoria Island, Lagos',
      'active': true,
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'title': 'Urgent Legal Documents Pickup',
      'category': 'Business & Legal',
      'date': 'Oct 14, 2:30 PM',
      'location': '8 Allen Avenue, Ikeja',
      'active': true,
      'icon': Icons.description_rounded,
    },
    {
      'title': 'Monthly Merchant Restock Delivery',
      'category': 'Store Inventory',
      'date': 'Oct 18, 9:00 AM',
      'location': 'Lekki Phase 1, Gate 2',
      'active': false,
      'icon': Icons.inventory_2_rounded,
    },
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showAddReminderModal() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    String category = 'Gift & Celebration';
    String dateStr = 'Tomorrow, 12:00 PM';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Schedule Delivery Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.black),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set an automated reminder for upcoming package pickups or deliveries.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Reminder Title / Event',
                  hintText: 'e.g. Anniversary Flowers Delivery',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.orange, width: 1.5)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: locationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Pickup / Dropoff Location',
                  hintText: 'e.g. 12 Admiralty Way, Lekki',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.orange, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      _toast('Please enter a reminder title');
                      return;
                    }
                    setState(() {
                      _reminders.insert(0, {
                        'title': titleController.text.trim(),
                        'category': category,
                        'date': dateStr,
                        'location': locationController.text.trim().isEmpty ? 'Specified Location' : locationController.text.trim(),
                        'active': true,
                        'icon': Icons.alarm_rounded,
                      });
                    });
                    Navigator.pop(ctx);
                    _toast('Delivery reminder scheduled successfully!');
                  },
                  child: const Text('SAVE REMINDER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'DELIVERY REMINDERS',
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.yellow, size: 26),
            onPressed: _showAddReminderModal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.orange, Color(0xFFD95F02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Never Miss a Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Schedule reminders for time-sensitive waybills, gifts, and merchant restocks.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scheduled Reminders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
              ),
              TextButton.icon(
                onPressed: _showAddReminderModal,
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.orange),
                label: const Text('Add New', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final rem = _reminders[idx];
              final isActive = rem['active'] == true;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(rem['icon'], color: AppColors.orange, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  rem['category'],
                                  style: const TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rem['title'],
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.black),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 13, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(rem['date'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_rounded, size: 13, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rem['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isActive,
                      activeColor: AppColors.yellow,
                      activeTrackColor: AppColors.orange,
                      onChanged: (val) {
                        setState(() => rem['active'] = val);
                        _toast(val ? 'Reminder enabled' : 'Reminder disabled');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
