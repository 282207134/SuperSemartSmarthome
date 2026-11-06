import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.kitchen = false});
  final bool kitchen;
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late bool kitchen = widget.kitchen;
  bool declined = false;
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    return PageFrame(
      title: 'Notification',
      back: false,
      tab: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Segments(
            items: const ['General (5)', 'Kitchen (2)'],
            value: kitchen ? 'Kitchen (2)' : 'General (5)',
            onChanged: (v) => setState(() => kitchen = v.startsWith('Kitchen')),
          ),
          const SizedBox(height: 28),
          Text(
            kitchen ? 'This Month' : 'Today',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (kitchen) ...[
            _alert(
              context,
              Icons.mail_outline,
              'Invitation Request',
              'Jakob Bergson is inviting you to join a community of homeowners who are taking control of their homes with ease.',
              '2 Feb 2023 • 5:42 pm',
              actions: s.invitationAccepted || declined
                  ? Text(
                      s.invitationAccepted
                          ? 'Invitation accepted'
                          : 'Invitation declined',
                      style: const TextStyle(color: blue),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => declined = true),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              s.invitationAccepted = true;
                              s.changed();
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
            ),
            _alert(
              context,
              Icons.celebration_outlined,
              'Congratulations!',
              'Your invitation to join Jakob Home has been accepted. Welcome to the smart home revolution!',
              '1 Feb 2023 • 1:40 pm',
            ),
          ] else ...[
            _alert(
              context,
              Icons.bolt_outlined,
              'Energy Usage Alert',
              'Keep track of your energy consumption and receive alerts when you’re close to hitting your monthly energy limit.',
              '2 Feb 2023 • 7:40 pm',
              onTap: () => go(context, '/energy'),
            ),
            _alert(
              context,
              Icons.smoke_free_outlined,
              'Smoke Detection Alert',
              'Stay safe with alerts if smoke is detected in your home, giving you peace of mind and the ability to take action quickly.',
              '2 Feb 2023 • 5:42 pm',
            ),
            _alert(
              context,
              Icons.thermostat_outlined,
              'Temperature Alert',
              'Stay informed about the temperature in your home and receive notifications if it goes above or below your desired range.',
              '2 Feb 2023 • 1:40 pm',
              onTap: () => go(context, '/ac'),
            ),
            const SizedBox(height: 8),
            Text('This Month', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _alert(
              context,
              Icons.mail_outline,
              'Invitation Request',
              'Get detailed information on energy consumption, usage patterns, and more.',
              '2 Jan 2023 • 5:42 pm',
              onTap: () => setState(() => kitchen = true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _alert(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    String time, {
    Widget? actions,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Panel(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: blue.withValues(alpha: .12),
                child: Icon(icon, color: blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: muted, height: 1.7),
          ),
          const SizedBox(height: 12),
          Text(time, style: const TextStyle(fontSize: 10, color: muted)),
          if (actions != null) ...[const SizedBox(height: 16), actions],
        ],
      ),
    ),
  );
}
