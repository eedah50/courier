import 'package:flutter/material.dart';
import 'theme.dart';

class SupportChatScreen extends StatefulWidget {
  final bool isCourierSupport;
  const SupportChatScreen({super.key, this.isCourierSupport = false});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();
  late final List<Map<String, dynamic>> _messages;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'sender': 'support',
        'text': widget.isCourierSupport
            ? 'Hello Driver! Welcome to Sekure 24/7 Courier Support. How can we assist you with your deliveries or payouts today?'
            : 'Hello! Welcome to Sekure 24/7 Customer Support. How can we help you with your waybills or orders today?',
        'time': 'Just now',
      },
    ];
  }

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
      _isTyping = true;
    });

    // Simulate automated support agent reply
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      String reply = 'Thank you for reaching out. Our support team has logged your request and is reviewing it.';

      final lower = text.toLowerCase();
      if (lower.contains('delay') || lower.contains('late')) {
        reply = 'We apologize for the delay. We are actively contacting the courier assigned to ensure prompt delivery.';
      } else if (lower.contains('payout') || lower.contains('money') || lower.contains('wallet')) {
        reply = 'Wallet and payout transactions are processed instantly. If your cashout is delayed, bank clearing takes up to 10 minutes.';
      } else if (lower.contains('verify') || lower.contains('document')) {
        reply = 'Driver verification reviews take between 12 to 24 hours. You will receive a notification once approved.';
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'support',
          'text': reply,
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
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCourierSupport ? 'DRIVER CARE 24/7' : 'CUSTOMER CARE 24/7',
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Online • Average reply < 2 mins',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: AppColors.yellow),
            tooltip: 'Call Support Hotline',
            onPressed: () => _toast('Connecting to Sekure Support Hotline...'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Inquiry Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SupportChip(
                    label: '📦 Delivery Delay',
                    onTap: () {
                      _messageController.text = 'I am experiencing a delivery delay.';
                      _sendMessage();
                    },
                  ),
                  _SupportChip(
                    label: '💰 Payout / Wallet',
                    onTap: () {
                      _messageController.text = 'I need help with my wallet/payout.';
                      _sendMessage();
                    },
                  ),
                  _SupportChip(
                    label: '📑 Verification Status',
                    onTap: () {
                      _messageController.text = 'When will my verification be reviewed?';
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
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                          ),
                          const SizedBox(width: 10),
                          const Text('Support agent is typing...', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isMe = msg['sender'] == 'me';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMe ? Icons.person_rounded : Icons.support_agent_rounded,
                              size: 14,
                              color: isMe ? AppColors.yellow : AppColors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isMe ? 'You' : 'Sekure Support Agent',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: isMe ? AppColors.yellow : AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                      hintText: 'Type your message to Support...',
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

class _SupportChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SupportChip({required this.label, required this.onTap});

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
