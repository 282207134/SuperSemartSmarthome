import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class SetupProgress extends StatelessWidget {
  const SetupProgress(this.step, {super.key});
  final int step;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      RoundButton(
        icon: Icons.arrow_back,
        label: 'Back',
        onTap: () => Navigator.of(context).canPop()
            ? Navigator.pop(context)
            : root(context, '/home'),
      ),
      const SizedBox(width: 24),
      Expanded(
        child: Row(
          children: List.generate(
            5,
            (i) => Expanded(
              child: Container(
                height: 12,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < step
                      ? blue
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Text(
          '$step/5',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

class HousePage extends StatefulWidget {
  const HousePage({super.key, this.edit = false});
  final bool edit;
  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final form = GlobalKey<FormState>();
  final home = TextEditingController(),
      owner = TextEditingController(),
      email = TextEditingController(),
      country = TextEditingController(),
      city = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final s = HomeScope.of(context);
      home.text = s.home;
      owner.text = s.owner;
      email.text = s.email;
      country.text = s.country;
      city.text = s.city;
      initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in [home, owner, email, country, city]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: widget.edit ? 'Edit Profile' : null,
    footer: FilledButton(
      onPressed: () async {
        if (!form.currentState!.validate()) return;
        final s = HomeScope.of(context);
        s.home = home.text.trim();
        s.owner = owner.text.trim();
        s.email = email.text.trim();
        s.country = country.text.trim();
        s.city = city.text.trim();
        await s.changed();
        if (context.mounted) {
          if (widget.edit) {
            Navigator.pop(context);
          } else {
            go(context, '/rooms');
          }
        }
      },
      child: Text(widget.edit ? 'Update Profile' : 'Next'),
    ),
    child: Form(
      key: form,
      child: Column(
        children: [
          if (!widget.edit) ...[
            const SetupProgress(1),
            const SizedBox(height: 24),
            Text('Add House', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Create a home for all your smart devices',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 24),
          ],
          Panel(
            onTap: () => toast(
              context,
              'Demo cover is bundled locally. Photo uploads are not connected.',
            ),
            child: SizedBox(
              height: 80,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.edit
                        ? Icons.add_a_photo_outlined
                        : Icons.add_photo_alternate_outlined,
                    color: blue,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload Cover',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.edit) ...[
            const Avatar(size: 64),
            const SizedBox(height: 16),
          ],
          Field(
            'Home Name',
            controller: home,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Enter a home name' : null,
          ),
          Field(
            'Owner',
            controller: owner,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Enter an owner' : null,
          ),
          if (widget.edit)
            Field(
              'Email',
              controller: email,
              keyboard: TextInputType.emailAddress,
              validator: (v) =>
                  RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                  ? null
                  : 'Enter a valid email',
            )
          else
            Row(
              children: [
                Expanded(child: Field('Country', controller: country)),
                const SizedBox(width: 16),
                Expanded(child: Field('City', controller: city)),
              ],
            ),
        ],
      ),
    ),
  );
}

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key, this.choose = false});
  final bool choose;
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    return PageFrame(
      footer: Row(
        children: [
          if (choose) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: FilledButton(
              onPressed: () =>
                  go(context, choose ? '/search' : '/setup-device'),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!choose) ...[const SetupProgress(2), const SizedBox(height: 24)],
          Text(
            choose ? 'Select Room' : 'Add Room',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            choose
                ? 'Select or create your own custom room in an easy and simple way'
                : 'Organize your devices by room',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: s.rooms.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 176,
            ),
            itemBuilder: (ctx, i) {
              if (i == s.rooms.length) {
                return Panel(
                  onTap: () => roomDialog(context),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: blue,
                        radius: 24,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Add another\nroom',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              final r = s.rooms[i];
              return Panel(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  s.room = r;
                  s.changed();
                },
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: choose
                          ? Icon(
                              r == s.room
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: r == s.room ? blue : muted,
                              size: 24,
                            )
                          : InkWell(
                              onTap: () => roomDialog(context, existing: r),
                              child: const Icon(Icons.more_horiz, size: 24),
                            ),
                    ),
                    AssetIcon(
                      i == 0
                          ? 'living'
                          : i == 1
                          ? 'bedroom'
                          : 'kitchen',
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      r,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.devices.where((d) => d.room == r).length} Devices',
                      style: const TextStyle(color: muted, fontSize: 12),
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

class PairingPage extends StatelessWidget {
  const PairingPage({super.key, this.stage = 0, this.wizard = false});
  final int stage;
  final bool wizard;
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    return PageFrame(
      title: wizard
          ? null
          : stage == 0
          ? 'Set Up Your Devices!'
          : 'Connecting Device',
      footer: FilledButton(
        onPressed: () async {
          if (stage == 0) {
            go(context, '/search${wizard ? '-setup' : ''}');
          } else if (stage == 1) {
            go(context, '/found${wizard ? '-setup' : ''}');
          } else {
            await s.addDevice();
            if (context.mounted) showAdded(context);
          }
        },
        child: Text(stage == 0 ? 'Add Device' : 'Connect'),
      ),
      child: Column(
        children: [
          if (wizard) ...[
            SetupProgress(stage + 3),
            const SizedBox(height: 24),
            Text(
              stage == 0 ? 'Set Up Your Devices!' : 'Connecting Device',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            stage == 0
                ? 'Connect your smart home devices to the app\nand start automating your home.'
                : stage == 1
                ? 'Press power button 5 Seconds'
                : 'Device found...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 24),
          Panel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 13,
                  backgroundColor: blue,
                  child: Icon(Icons.wifi, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  stage == 0 ? s.room : 'Turn on Wi-Fi to connect',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),
          SizedBox(
            height: 300,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final size in [290.0, 230.0, 170.0])
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  Icon(
                    stage == 0
                        ? Icons.devices_other
                        : stage == 1
                        ? Icons.phonelink_ring_outlined
                        : Icons.tv_outlined,
                    size: stage == 2 ? 130 : 74,
                    color: blue,
                  ),
                ],
              ),
            ),
          ),
          if (stage == 2)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Samsung UA55 4AC', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Connect your device'),
                content: const Text(
                  'Use a 2.4 GHz Wi-Fi network and hold the device power button for 5 seconds.\n\nThis demo simulates discovery and pairing; no real device is scanned.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
            child: const Text('Learn More'),
          ),
          const Text(
            'You need an active Wi-Fi connection\non your mobile device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text(
            'Simulated pairing · local demo',
            style: TextStyle(fontSize: 10, color: muted),
          ),
        ],
      ),
    );
  }
}

Future<void> showAdded(BuildContext context) => showModalBottomSheet(
  context: context,
  isDismissible: false,
  backgroundColor: Theme.of(context).colorScheme.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (ctx) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: blue, size: 64),
        const SizedBox(height: 24),
        Text(
          'Device Added to\n“${HomeScope.of(context).room}”',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            root(context, '/home');
            go(context, '/device/added-tv-${HomeScope.of(context).room}');
          },
          child: const Text('View Device'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            root(context, '/home');
          },
          child: const Text('Done'),
        ),
      ],
    ),
  ),
);
