import 'package:flutter/material.dart';

import 'home_store.dart';
import 'theme.dart';

void go(BuildContext context, String route) =>
    Navigator.of(context).pushNamed(route);
void root(BuildContext context, String route) =>
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
void toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
    .showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
    this.background,
    this.size = 56,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final Color? color, background;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: IconButton.filled(
      tooltip: label,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: background ?? Theme.of(context).colorScheme.surface,
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      icon: Icon(icon, size: size * .43),
    ),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.title,
    this.back = true,
    this.tab,
    this.footer,
    this.trailing,
    this.scroll = true,
  });
  final Widget child;
  final String? title;
  final bool back, scroll;
  final int? tab;
  final Widget? footer, trailing;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  if (back)
                    RoundButton(
                      icon: Icons.arrow_back,
                      label: 'Back',
                      onTap: () => Navigator.of(context).canPop()
                          ? Navigator.pop(context)
                          : root(context, '/home'),
                    ),
                  if (back) const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          Expanded(
            child: scroll
                ? SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      title == null ? 28 : 8,
                      24,
                      24,
                    ),
                    child: child,
                  )
                : child,
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: footer!,
            ),
          if (tab != null) BottomDock(index: tab!),
          if (HomeScope.of(context).saveError != null)
            Text(
              HomeScope.of(context).saveError!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
        ],
      ),
    ),
  );
}

class BottomDock extends StatelessWidget {
  const BottomDock({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    margin: const EdgeInsets.fromLTRB(19, 0, 19, 20),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(44),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final item in [
          (Icons.home_outlined, '/home', 'Home'),
          (Icons.bolt_outlined, '/energy', 'Energy'),
          (Icons.add, '/choose-room', 'Add device'),
          (Icons.notifications_none, '/notifications', 'Notifications'),
          (Icons.person_outline, '/profile', 'Profile'),
        ].asMap().entries)
          IconButton(
            tooltip: item.value.$3,
            onPressed: () => item.key == 2
                ? go(context, item.value.$2)
                : root(context, item.value.$2),
            style: IconButton.styleFrom(
              backgroundColor: item.key == 2 ? blue : Colors.transparent,
              fixedSize: Size.square(item.key == 2 ? 48 : 44),
            ),
            icon: Icon(
              item.value.$1,
              color: item.key == index || item.key == 2
                  ? Colors.white
                  : const Color(0xFF8994B4),
              size: 26,
            ),
          ),
      ],
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class AssetIcon extends StatelessWidget {
  const AssetIcon(this.name, {super.key, this.size = 34});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/icon_$name.png', width: size, height: size);
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 48, this.bot = false});
  final double size;
  final bool bot;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Container(
      color: Theme.of(context).colorScheme.surface,
      width: size,
      height: size,
      child: Transform.scale(
        scale: bot ? 1 : 3,
        alignment: const Alignment(0, -.5),
        child: Image.asset(
          'assets/images/${bot ? 'bot' : 'avatar'}.png',
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

class Field extends StatelessWidget {
  const Field(
    this.label, {
    super.key,
    this.controller,
    this.hint,
    this.obscure = false,
    this.validator,
    this.keyboard,
    this.suffix,
    this.onChanged,
  });
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey(label),
          controller: controller,
          obscureText: obscure,
          validator: validator,
          keyboardType: keyboard,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
}

class Segments extends StatelessWidget {
  const Segments({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      children: items
          .map(
            (t) => Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => onChanged(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: t == value
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    t,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: t == value ? blue : muted,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

Future<void> roomDialog(BuildContext context, {String? existing}) async {
  final controller = TextEditingController(text: existing ?? '');
  String? error;
  final value = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(ctx).bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Another Room' : 'Edit Room',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Field('Room Name', controller: controller, hint: 'Relax Room'),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty ||
                    (HomeScope.of(context).rooms.contains(name) &&
                        name != existing)) {
                  setState(() => error = 'Enter a unique room name.');
                  return;
                }
                Navigator.pop(ctx, name);
              },
              child: Text(existing == null ? 'Create Room' : 'Update'),
            ),
          ],
        ),
      ),
    ),
  );
  if (value != null && context.mounted) {
    await HomeScope.of(context).addRoom(value, replacing: existing);
  }
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
}
