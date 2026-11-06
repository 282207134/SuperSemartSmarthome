import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key, this.ac = false, this.deviceId});
  final bool ac;
  final String? deviceId;
  @override
  Widget build(BuildContext context) {
    final s = HomeScope.of(context);
    final device = s.devices
        .where((d) => d.id == (deviceId ?? (ac ? 'ac' : 'lamp')))
        .firstOrNull;
    final generic =
        deviceId != null && device?.kind != 'lamp' && device?.kind != 'ac';
    final value = ac ? s.temperature : s.intensity;
    Future<void> time(bool start) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: start ? 11 : 19, minute: 0),
      );
      if (picked != null && context.mounted) {
        final text = picked.format(context);
        if (start) {
          s.from = text;
        } else {
          s.to = text;
        }
        s.changed();
      }
    }

    return PageFrame(
      title: generic
          ? device?.name ?? 'Device'
          : ac
          ? 'Air Conditioner'
          : 'Smart Lamp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              generic
                  ? 'Connected to ${device?.room ?? s.room}'
                  : ac
                  ? 'Device 1: Samsung AR05KRFLAWKN ⌄'
                  : 'Device 1: Ikea NIFORS ⌄',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: RoundButton(
              icon: Icons.power_settings_new,
              label: 'Device power',
              onTap: () {
                if (device != null) s.toggle(device);
              },
              background: device?.on == true
                  ? blue
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              color: device?.on == true ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 28),
          if (generic)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(55),
                child: Column(
                  children: [
                    AssetIcon(device?.kind ?? 'tv', size: 100),
                    const SizedBox(height: 24),
                    Text(
                      device?.on == true ? 'On' : 'Off',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Connected via Wi-Fi',
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Semantics(
                label: ac ? 'Temperature control' : 'Brightness control',
                child: SizedBox.square(
                  dimension: 280,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final p = details.localPosition - const Offset(140, 140);
                      var a = math.atan2(p.dy, p.dx) + math.pi / 2;
                      if (a < 0) a += math.pi * 2;
                      if (ac) {
                        var angle = math.atan2(p.dy, p.dx) - math.pi;
                        if (angle < 0) angle += math.pi * 2;
                        s.temperature = (16 + angle / (math.pi * 1.5) * 14)
                            .clamp(16, 30);
                      } else {
                        s.intensity = (a / (math.pi * 2) * 100).clamp(0, 100);
                      }
                      s.changed();
                    },
                    child: CustomPaint(
                      painter: DialPainter(
                        progress: ac ? (value - 16) / 14 : value / 100,
                        color: ac
                            ? blue
                            : s.lampMode == 'Warm'
                            ? const Color(0xFFFFC327)
                            : s.lampMode == 'Romantic'
                            ? Colors.pinkAccent
                            : blue,
                        dark: s.dark,
                        ac: ac,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ac ? Icons.thermostat : Icons.light_mode_outlined,
                            color: blue,
                            size: 30,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            ac ? '${value.round()} °C' : '${value.round()}%',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ac ? s.acMode : 'Intensity',
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!generic) ...[
            const SizedBox(height: 28),
            if (!ac) ...[
              Text('Mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 18),
            ],
            Segments(
              items: ac
                  ? ['Cooling', 'Fan', 'Dry', 'Auto']
                  : ['Warm', 'Color', 'Romantic'],
              value: ac ? s.acMode : s.lampMode,
              onChanged: (m) {
                if (ac) {
                  s.acMode = m;
                } else {
                  s.lampMode = m;
                }
                s.changed();
              },
            ),
            const SizedBox(height: 22),
            if (!ac) ...[
              Row(
                children: [
                  const Icon(Icons.light_mode_outlined, color: blue),
                  Expanded(
                    child: Slider(
                      label: '${value.round()}%',
                      value: value,
                      max: 100,
                      onChanged: (v) {
                        s.intensity = v;
                        s.changed();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'From',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () => time(true),
                      child: Text('${s.from} ⌄'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'To',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => time(false),
                      child: Text('${s.to} ⌄'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Slider(
                label: '${value.round()} °C',
                value: value,
                min: 16,
                max: 30,
                divisions: 14,
                onChanged: (v) {
                  s.temperature = v;
                  s.changed();
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Panel(
                      color: blue,
                      onTap: () async {
                        final v = await showDialog<int>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Timer'),
                            children: [
                              for (final h in [1, 2, 4, 7, 12])
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(ctx, h),
                                  child: Text('$h Hours'),
                                ),
                            ],
                          ),
                        );
                        if (v != null) {
                          s.timer = v;
                          s.changed();
                        }
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${s.timer} Hours',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Text(
                            'Timer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Panel(
                      onTap: () {
                        s.scenes = !s.scenes;
                        s.changed();
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.eco_outlined, size: 30),
                          const SizedBox(height: 16),
                          Text(s.scenes ? 'On' : 'Off'),
                          const Text(
                            'Scenes',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Panel(
                      onTap: () {
                        s.fastSwing = !s.fastSwing;
                        s.changed();
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.open_in_full, size: 30),
                          const SizedBox(height: 16),
                          Text(s.fastSwing ? 'Fast' : 'Slow'),
                          const Text(
                            'Swing',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class DialPainter extends CustomPainter {
  DialPainter({
    required this.progress,
    required this.color,
    required this.dark,
    required this.ac,
  });
  final double progress;
  final Color color;
  final bool dark, ac;
  @override
  void paint(Canvas c, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: 102);
    final base = dark ? const Color(0xFF343438) : const Color(0xFFDFE3E9);
    c.drawCircle(
      center,
      88,
      Paint()
        ..shader = RadialGradient(
          colors: [
            dark ? const Color(0xFF29292C) : const Color(0xFFF2F4F7),
            base,
          ],
        ).createShader(rect),
    );
    c.drawCircle(
      center,
      102,
      Paint()
        ..color = base
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24,
    );
    final start = ac ? math.pi : -math.pi / 2;
    final sweep = ac ? math.pi * 1.5 * progress : math.pi * 2 * progress;
    c.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [color, color.withValues(alpha: .4)],
          startAngle: 0,
          endAngle: math.pi * 2,
        ).createShader(rect)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24,
    );
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final p = Offset(math.cos(a), math.sin(a));
      c.drawLine(
        center + p * 130,
        center + p * 135,
        Paint()
          ..color = base
          ..strokeWidth = 2,
      );
    }
    final knob =
        center + Offset(math.cos(start + sweep), math.sin(start + sweep)) * 102;
    c.drawShadow(
      Path()..addOval(Rect.fromCircle(center: knob, radius: 19)),
      Colors.black38,
      5,
      true,
    );
    c.drawCircle(
      knob,
      19,
      Paint()..color = dark ? const Color(0xFF55555C) : const Color(0xFFF4F5F8),
    );
    c.drawCircle(
      knob,
      19,
      Paint()
        ..color = base
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(DialPainter old) =>
      old.progress != progress || old.color != color || old.dark != dark;
}
