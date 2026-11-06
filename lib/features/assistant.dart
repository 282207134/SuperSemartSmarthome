import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/widgets.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: blue,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.pop(context)
                    : root(context, '/home'),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            Expanded(
              flex: 5,
              child: Image.asset(
                'assets/images/assistant.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We Always There',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'If you have any other questions or need further\nassistance, don’t hesitate to ask.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.8,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  54,
                  (i) => Container(
                    width: 2,
                    height:
                        4 +
                        44 *
                            (math.sin(i * .63) * math.sin(i / 54 * math.pi))
                                .abs(),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: .35 + .65 * math.sin(i / 54 * math.pi),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoundButton(
                  icon: Icons.mic_none,
                  onTap: () => toast(
                    context,
                    'Voice input is not enabled. Use the chat keyboard.',
                  ),
                  label: 'Voice input',
                  background: Colors.white12,
                  color: Colors.white,
                ),
                RoundButton(
                  icon: Icons.auto_awesome,
                  onTap: () => go(context, '/chat'),
                  label: 'Start assistant chat',
                  background: Colors.white24,
                  color: Colors.white,
                  size: 80,
                ),
                RoundButton(
                  icon: Icons.keyboard_outlined,
                  onTap: () => go(context, '/chat'),
                  label: 'Open chat',
                  background: Colors.white12,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Local demo assistant',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.draft = false});
  final bool draft;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController(), scroll = ScrollController();
  final messages = <({bool user, String text})>[
    (
      user: false,
      text:
          'Hi! 👋 I’m a Bot. Let me know if you have any question or request.',
    ),
    (
      user: true,
      text: 'I need help connecting my smart home devices to the app.',
    ),
    (
      user: false,
      text: 'Of course! I’d be happy to assist. What type of devices are you trying to connect?',
    ),
    (user: true, text: 'I have some smart lights'),
    (
      user: false,
      text: 'Great! First, make sure your devices are compatible with Smart Home App. Then, open the app and go to the device connection page. Follow the steps to connect each device to your home network.',
    ),
  ];
  @override
  void initState() {
    super.initState();
    if (widget.draft) input.text = 'I’ve done that, but';
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    final text = input.text.trim();
    if (text.isEmpty) return;
    final q = text.toLowerCase();
    final reply = q.contains('light') || q.contains('lamp')
        ? 'Open Smart Lamp from Home. Adjust the intensity slider, choose Warm, Color or Romantic, and set your schedule.'
        : q.contains('energy')
        ? 'Open Energy Saving to compare monthly usage. Tap a daily bar to inspect the sample kWh reading.'
        : q.contains('temperature') || q.contains('air')
        ? 'Open Air Conditioner and adjust the temperature between 16 °C and 30 °C. You can also set its timer, scenes and swing.'
        : q.contains('connect') || q.contains('device')
        ? 'Tap + on the bottom navigation, choose a room, then tap Connect. In this demo discovery is simulated; real devices require a hardware integration.'
        : 'I can help with lights, air conditioning, energy and device setup. What would you like to explore?';
    setState(() {
      messages.add((user: true, text: text));
      messages.add((user: false, text: reply));
      input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'SemartBot',
    trailing: const Avatar(bot: true, size: 56),
    scroll: false,
    footer: Row(
      children: [
        RoundButton(
          icon: Icons.add,
          label: 'Add device from chat',
          onTap: () => go(context, '/choose-room'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: input,
            onSubmitted: (_) => send(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Ask anything...',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              suffixIcon: IconButton(
                tooltip: 'Send message',
                onPressed: send,
                icon: const Icon(Icons.send_rounded, color: blue),
              ),
            ),
          ),
        ),
      ],
    ),
    child: Column(
      children: [
        const Text(
          '● Online · local demo',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: m.user
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!m.user) ...[
                      const Avatar(bot: true, size: 32),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .68,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: m.user
                              ? blue
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(30),
                            topRight: const Radius.circular(30),
                            bottomLeft: const Radius.circular(30),
                            bottomRight: Radius.circular(m.user ? 0 : 30),
                          ),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.user ? Colors.white : null,
                            fontSize: 12,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
