import 'package:flutter/material.dart';
import 'theme.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String peerName;
  final String peerRole; // 'Courier' or 'Customer'
  final String peerPhone;
  final String vehicleInfo;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.peerName,
    required this.peerRole,
    required this.peerPhone,
    this.vehicleInfo = 'Honda Ace 125 • LA-492-IKJ',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'peer',
      'text': 'Hello! I have accepted your delivery request and am on my way to the pickup location.',
      'time': '10:24 AM',
    },
    {
      'sender': 'me',
      'text': 'Great! Please call me when you arrive at the gate.',
      'time': '10:25 AM',
    },
    {
      'sender': 'peer',
      'text': 'Will do! Estimated arrival is in 12 minutes.',
      'time': '10:26 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'me',
        'text': text,
        'time': 'Just now',
      });
      _messageController.clear();
    });

    // Simulate auto-reply from courier/customer after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'peer',
          'text': 'Received your message loud and clear!',
          'time': 'Just now',
        });
      });
    });
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
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${widget.peerRole} • ${widget.vehicleInfo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: AppColors.yellow),
            tooltip: 'Call ${widget.peerName}',
            onPressed: () => _toast('Calling ${widget.peerPhone}...'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Active Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFFBEB),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded, color: AppColors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active Waybill #${widget.orderId} • Secure In-Trip Chat',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.black),
                  ),
                ),
              ],
            ),
          ),

          // Quick Preset Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChatChip(
                    label: '📍 Where are you?',
                    onTap: () {
                      _messageController.text = 'Where are you currently located?';
                      _sendMessage();
                    },
                  ),
                  _QuickChatChip(
                    label: '🚪 I am at the door',
                    onTap: () {
                      _messageController.text = 'I am at the dropoff location door.';
                      _sendMessage();
                    },
                  ),
                  _QuickChatChip(
                    label: '📞 Please call me',
                    onTap: () {
                      _messageController.text = 'Please call my phone when you arrive.';
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender'] == 'me';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.black : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isMe ? null : Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.black,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'],
                            style: TextStyle(
                              color: isMe ? Colors.white60 : Colors.black45,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message to ${widget.peerName}...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChatChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChatChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.black),
        ),
        onPressed: onTap,
      ),
    );
  }
}
