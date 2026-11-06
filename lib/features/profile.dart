import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    return PageFrame(
      title: s.home,
      back: false,
      tab: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Avatar(size: 56),
            title: Text(
              s.owner,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Owner',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: blue),
            onTap: () => go(context, '/edit-profile'),
          ),
          const SizedBox(height: 26),
          const Text('General', style: TextStyle(color: muted)),
          const SizedBox(height: 12),
          for (final item in [
            (Icons.settings_outlined, 'Settings', '/settings'),
            (
              Icons.notifications_none,
              'Notification',
              '/notification-settings',
            ),
            (Icons.person_pin_outlined, 'Members', '/members'),
            (Icons.language, 'Language', '/language'),
          ])
            _ProfileLink(item.$1, item.$2, item.$3),
          const SizedBox(height: 16),
          const Text('Support', style: TextStyle(color: muted)),
          const SizedBox(height: 12),
          const _ProfileLink(
            Icons.support_agent_outlined,
            'Help Center',
            '/help',
          ),
          const _ProfileLink(Icons.info_outline, 'About Us', '/about'),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => showAccounts(context),
            child: const Text('Switch Account'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink(this.icon, this.label, this.route);
  final IconData icon;
  final String label, route;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
      title: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (label == 'Members') ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                '${HomeScope.of(context).members.length}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: blue),
      onTap: () => go(context, route),
    ),
  );
}

Future<void> showAccounts(BuildContext context) => showModalBottomSheet(
  context: context,
  backgroundColor: Theme.of(context).colorScheme.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (ctx) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close),
            ),
            const Text(
              'Switch Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final house in ['Jakob Home', 'Kianna Home'])
          ListTile(
            leading: const Avatar(size: 40),
            title: Text(house, style: const TextStyle(fontSize: 14)),
            subtitle: const Text(
              'Demo household',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            trailing: Icon(
              HomeScope.of(context).home == house
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: blue,
            ),
            onTap: () {
              final s = HomeScope.of(context);
              s.home = house;
              s.changed();
              Navigator.pop(ctx);
            },
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(ctx);
            go(context, '/add-house');
          },
          child: const Text('Add Other House'),
        ),
      ],
    ),
  ),
);
Future<void> showLogout(BuildContext context) => showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    icon: const Icon(Icons.logout, color: blue, size: 48),
    title: const Text('Log Out!'),
    content: const Text('Are you sure you want to log out of SuperSemart?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          final s = HomeScope.of(context);
          s.signedIn = false;
          s.changed();
          Navigator.pop(ctx);
          root(context, '/sign-in');
        },
        child: const Text('Log Out'),
      ),
    ],
  ),
);

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key, required this.kind});
  final String kind;
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    final kind = widget.kind;
    Widget toggle(String label, bool value, ValueChanged<bool> change) =>
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          title: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          value: value,
          onChanged: (v) {
            change(v);
            s.changed();
          },
        );
    final title = kind == 'settings'
        ? 'Settings'
        : kind == 'notification-settings'
        ? 'Notification'
        : kind == 'members'
        ? 'Members'
        : kind == 'language'
        ? 'Language'
        : 'About Us';
    return PageFrame(
      title: title,
      footer: kind == 'members'
          ? FilledButton(
              onPressed: () => _addMember(context),
              child: const Text('Add Members'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kind == 'settings') ...[
            toggle('Allow Remote Access', s.remote, (v) => s.remote = v),
            toggle('Allow Editing', s.editing, (v) => s.editing = v),
            toggle('Allow Add Member', s.addMembers, (v) => s.addMembers = v),
            const SizedBox(height: 20),
            const Divider(),
            toggle('Dark Mode', s.dark, (v) => s.dark = v),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => go(context, '/rooms'),
              child: const Text('Manage Rooms'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => showLogout(context),
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
          if (kind == 'notification-settings') ...[
            toggle('Push Notification', s.push, (v) => s.push = v),
            toggle(
              'Temperature',
              s.temperatureAlerts,
              (v) => s.temperatureAlerts = v,
            ),
            toggle('Sound', s.sound, (v) => s.sound = v),
            const SizedBox(height: 16),
            const Text(
              'Preferences are saved locally in this demo.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
          if (kind == 'members')
            for (final m in s.members.asMap().entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: m.key == 0
                      ? const Avatar(size: 56)
                      : CircleAvatar(
                          radius: 28,
                          backgroundColor: blue.withValues(alpha: .12),
                          child: Text(
                            m.value.split(' ').map((x) => x[0]).take(2).join(),
                            style: const TextStyle(color: blue),
                          ),
                        ),
                  title: Text(
                    m.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    m.key == 0
                        ? 'Owner'
                        : m.key == 3
                        ? '4 rooms'
                        : 'Full Access',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ),
              ),
          if (kind == 'language') ...[
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            const SizedBox(height: 24),
            for (final group in [
              ('Suggestion', ['English (US)', 'Indonesia']),
              (
                'All Language',
                [
                  'Albanian',
                  'Arabic',
                  'Azerbaijani',
                  'Belarusian',
                  'Bosnian',
                  'Bulgarian',
                  'Brazil',
                  'Chinese',
                  'Japanese',
                ],
              ),
            ]) ...[
              Text(
                group.$1,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              for (final lang in group.$2.where(
                (l) => l.toLowerCase().contains(query.toLowerCase()),
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lang, style: const TextStyle(fontSize: 14)),
                  trailing: Icon(
                    s.language == lang
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: s.language == lang ? blue : muted,
                  ),
                  onTap: () {
                    s.language = lang;
                    s.changed();
                  },
                ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Language preference is saved. This UI kit uses English copy.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
          if (kind == 'about') ...[
            const SizedBox(height: 24),
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: blue,
                child: Icon(Icons.home_outlined, color: Colors.white, size: 58),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'SuperSemart',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'What we offer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to our Smarthome App, where technology and comfort meet to revolutionize the way you live. Our app is designed to bring convenience and simplicity to your daily routine, making your home a smarter place.\n\nControl lighting, set a comfortable temperature, manage rooms and keep track of energy consumption from one place. Invite your family and make everyone feel at home.\n\nThis Flutter demonstration is based on the SuperSemart Pixso UI kit. Devices, weather, energy readings, notifications and assistant replies use local sample data. Authentication, cloud sync and hardware connections are not enabled.',
              style: TextStyle(fontSize: 13, height: 1.9),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addMember(BuildContext context) async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: 'Member name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) Navigator.pop(ctx, c.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && context.mounted) {
      final s = HomeScope.of(context);
      if (!s.members.contains(name)) {
        s.members.add(name);
        await s.changed();
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    c.dispose();
  }
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String query = '';
  int open = 0;
  static const questions = [
    'What is the smarthome app and what does it do?',
    'Is the app compatible with all smart home devices?',
    'How do I set up and install the app?',
  ];
  static const answers = [
    'The smarthome app allows you to control and manage your smart home devices from a single platform. Monitor lights, thermostats, security systems and other connected devices.',
    'Compatibility depends on your device model and connection protocol. This demo uses simulated Wi-Fi devices; check the manufacturer specifications before connecting real hardware.',
    'Create a home, choose a room, then tap Add Device. Turn on Wi-Fi and follow the connection steps. In this demo, pairing is simulated locally.',
  ];
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Help Center',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          color: blue,
          child: Column(
            children: [
              const Text(
                'How can we help?',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 4),
              const Text(
                'A fully functional search system',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: Color(0xFF1C1C1E)),
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: muted),
                  hintText: 'Search...',
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => toast(
                  context,
                  'Support email is not configured. Please use the help articles.',
                ),
                child: const Text(
                  'Email Support',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => go(context, '/chat'),
                child: const Text('Live Chat', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Frequent Question',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          'Help you identify what you need faster.',
          style: TextStyle(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < questions.length; i++)
          if ('${questions[i]} ${answers[i]}'.toLowerCase().contains(
            query.toLowerCase(),
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Panel(
                padding: const EdgeInsets.all(16),
                onTap: () => setState(() => open = open == i ? -1 : i),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${i + 1}. ${questions[i]}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(open == i ? Icons.close : Icons.add, size: 20),
                      ],
                    ),
                    if (open == i) ...[
                      const SizedBox(height: 12),
                      Text(
                        answers[i],
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        if (query.isNotEmpty &&
            !questions.asMap().entries.any(
              (e) => '${e.value} ${answers[e.key]}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
            ))
          const Center(child: Text('No matching articles')),
      ],
    ),
  );
}
