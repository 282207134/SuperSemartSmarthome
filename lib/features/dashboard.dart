import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    final devices = s.devices.where((d) => d.room == s.room).toList();
    Widget card(SmartDevice d, {bool tall = false}) => Panel(
      padding: const EdgeInsets.all(16),
      onTap: () => go(
        context,
        d.kind == 'lamp'
            ? '/lamp/${d.id}'
            : d.kind == 'ac'
            ? '/ac/${d.id}'
            : '/device/${d.id}',
      ),
      child: SizedBox(
        height: tall ? 166 : 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssetIcon(d.kind, size: 32),
            const SizedBox(height: 12),
            Text(
              d.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            if (tall)
              const Text(
                '• Bardi smart lamp\n• Smart lamp\n• Smart lamp',
                style: TextStyle(fontSize: 10, height: 1.6, color: muted),
              )
            else
              Text(
                '${d.kind == 'tv' ? 1 : 2} Devices',
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi, size: 14, color: muted),
                      SizedBox(width: 4),
                      Text(
                        'Wi-Fi',
                        style: TextStyle(fontSize: 10, color: muted),
                      ),
                    ],
                  ),
                ),
                RoundButton(
                  icon: Icons.power_settings_new,
                  label: 'Power ${d.name}',
                  onTap: () => s.toggle(d),
                  size: 34,
                  background: d.on
                      ? blue
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: d.on ? Colors.white : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return PageFrame(
      tab: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => go(context, '/profile'),
                child: const Avatar(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${s.owner}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${s.devices.where((d) => d.on).length} devices on',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => go(context, '/assistant'),
                child: const Avatar(size: 56, bot: true),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            height: 178,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: blue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 36,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jakarta, Indonesia',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Little Rain',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lowering the temp. below\n16 °C cut cost by \$80',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '18 °C',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/weather.png',
                  width: MediaQuery.sizeOf(context).width < 380 ? 104 : 126,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: s.rooms.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final r = s.rooms[i];
                final selected = r == s.room;
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    s.room = r;
                    s.changed();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? navy
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '$r${selected ? ' (${devices.length})' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (devices.isEmpty)
            Panel(
              child: Column(
                children: [
                  const Icon(Icons.devices_other, size: 48, color: blue),
                  const SizedBox(height: 16),
                  const Text('Make this room smarter'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => go(context, '/search'),
                    child: const Text('Add Device'),
                  ),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < devices.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: card(
                            devices[i],
                            tall: i == 0 && devices[i].kind == 'lamp',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 1; i < devices.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: card(devices[i]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class EnergyPage extends StatefulWidget {
  const EnergyPage({super.key});
  @override
  State<EnergyPage> createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  int day = 3;
  String period = 'Today';
  final usage = [62, 78, 36, 48, 73, 36, 56];
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Energy Saving',
    back: false,
    tab: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: period,
          underline: const SizedBox(),
          items: ['Today', 'This Week', 'This Month']
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    '$p: Energy Usage ${p == 'Today'
                        ? '48.8'
                        : p == 'This Week'
                        ? '389'
                        : '580.012'} kWh',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
          onChanged: (p) => setState(() => period = p!),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (final m in [
              ('This Month', '580.012 kWh', const Color(0xFFFF7048)),
              ('Previous Month', '980.012 kWh', navy),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Panel(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: m.$3,
                          child: const Icon(Icons.bolt, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.$1,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                m.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => day = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 38,
                        height: usage[i] * 1.8,
                        decoration: BoxDecoration(
                          color: i == day
                              ? blue
                              : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: i == day
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Icon(
                                      Icons.bolt,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      '${usage[i]}\nkWh',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${i + 1} Dec',
                        style: const TextStyle(fontSize: 10, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text('Devices', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 18),
        Row(
          children: [
            for (final d in [
              ('tv', 'Smart TV', '80', '46'),
              ('ac', 'Air Conditioner', '50', '16'),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Panel(
                    onTap: () =>
                        go(context, d.$1 == 'ac' ? '/ac' : '/device/tv'),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AssetIcon(d.$1),
                        const SizedBox(height: 40),
                        Text(
                          d.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Consuming ${d.$3} kWh',
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${d.$4}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
