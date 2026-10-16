import 'package:flutter/material.dart';
import 'theme.dart';

class AiAssistantScreen extends StatefulWidget {
  final bool isCourierMode;
  const AiAssistantScreen({super.key, this.isCourierMode = false});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'text': 'Hello! I am Sekure AI, your intelligent delivery & logistics copilot. How can I help you optimize your shipments or route today?',
      'time': 'Just now',
    },
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': 'Just now',
      });
      _messageController.clear();
      _isTyping = true;
    });

    // Simulate AI Intelligence Response
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      String aiReply = 'I have analyzed your request using Sekure Logistics AI.';
      
      final lower = text.toLowerCase();
      if (lower.contains('track') || lower.contains('where')) {
        aiReply = 'Waybill #SKR-8842 is currently In Transit with Courier Chukwuma Adebayo. Estimated arrival in 14 minutes.';
      } else if (lower.contains('price') || lower.contains('cost') || lower.contains('fee')) {
        aiReply = 'Standard delivery fare is estimated at ₦3,500 - ₦4,500 based on weight (2.5kg) and distance (6.4 km).';
      } else if (lower.contains('route') || lower.contains('traffic') || lower.contains('fast')) {
        aiReply = 'AI Route Optimizer suggests taking the Lekki-Ikoyi Link Bridge to avoid heavy traffic on Admiralty Way. Estimated time saved: 8 mins.';
      } else if (lower.contains('fatigue') || lower.contains('tired') || lower.contains('rest')) {
        aiReply = 'Safety Alert: You have been riding for 4 hours straight. I recommend taking a 15-minute rest break to stay alert and hydrated!';
      } else if (lower.contains('earnings') || lower.contains('money') || lower.contains('payout')) {
        aiReply = 'Your projected weekly earnings are ₦124,500 with 98% driver rating. Peak surge hours start at 5:00 PM today!';
      } else {
        aiReply = 'Got it! Sekure AI is monitoring your shipments, traffic updates, and safety protocols in real time.';
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'ai',
          'text': aiReply,
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
                color: AppColors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: AppColors.black, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEKURE AI COPILOT',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Intelligent Logistics & Safety Assistant',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Prompt Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickPromptChip(
                    label: '📦 Where is my package?',
                    onTap: () {
                      _messageController.text = 'Where is my package?';
                      _sendMessage();
                    },
                  ),
                  _QuickPromptChip(
                    label: '🗺️ Optimize Fastest Route',
                    onTap: () {
                      _messageController.text = 'Optimize fastest route';
                      _sendMessage();
                    },
                  ),
                  _QuickPromptChip(
                    label: '💰 Calculate Delivery Cost',
                    onTap: () {
                      _messageController.text = 'Calculate delivery cost';
                      _sendMessage();
                    },
                  ),
                  _QuickPromptChip(
                    label: '☕ Driver Fatigue Check',
                    onTap: () {
                      _messageController.text = 'Check driver fatigue';
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Chat Messages List
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
                          Text('Sekure AI is thinking...', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isAi = msg['sender'] == 'ai';

                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.white : AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isAi ? Border.all(color: Colors.black12) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAi ? Icons.psychology_rounded : Icons.person_rounded,
                              size: 14,
                              color: isAi ? AppColors.orange : AppColors.yellow,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAi ? 'Sekure AI Copilot' : 'You',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: isAi ? AppColors.orange : AppColors.yellow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isAi ? AppColors.black : Colors.white,
                            fontSize: 13.5,
                            height: 1.4,
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
                      hintText: 'Ask Sekure AI anything about delivery or routes...',
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

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({required this.label, required this.onTap});

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
