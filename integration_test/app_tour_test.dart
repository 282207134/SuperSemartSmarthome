import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_smart_home/app.dart';
import 'package:super_smart_home/core/home_store.dart';
import 'package:super_smart_home/core/theme.dart';
import 'package:super_smart_home/core/widgets.dart';
import 'package:super_smart_home/features/onboarding.dart';
import 'package:super_smart_home/features/profile.dart';
import 'package:super_smart_home/features/setup.dart';

import 'screen_routes.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const captureOnly = bool.fromEnvironment('CAPTURE_ONLY');
  const screenshotIds = String.fromEnvironment('SCREENSHOT_IDS');
  bool wanted(String name) =>
      screenshotIds.isEmpty ||
      screenshotIds.split(',').contains(name.split('/').last.split('_').first);
  testWidgets('Pixso screen tour, local controls, pairing and persistence', (
    tester,
  ) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final store = HomeStore(await SharedPreferences.getInstance());
    final original = store.toJson();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      SuperSmartApp(store: store, initialRoute: '/home', navigatorKey: nav),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    Future<void> open(String route) async {
      nav.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
      await tester.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      if (!wanted(name)) return;
      debugPrint('Capturing $name');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull, reason: name);
      await binding.takeScreenshot(name);
    }

    final pages = <(String, String)>[
      ('01_splash_screen', '/splash'),
      ('02_onboarding', '/welcome'),
      ('03_sign_up', '/sign-up'),
      ('04_sign_in', '/sign-in'),
      ('05_forgot_password', '/forgot'),
      ('06_reset_password', '/reset'),
      ('07_verify_code', '/verify'),
      ('09_add_house', '/add-house'),
      ('10_add_room', '/rooms'),
      ('13_setup_devices', '/setup-device'),
      ('14_search_setup', '/search-setup'),
      ('15_found_setup', '/found-setup'),
      ('16_home', '/home'),
      ('17_lamp_warm', '/lamp'),
      ('19_air_conditioner', '/ac'),
      ('20_energy_saving', '/energy'),
      ('21_choose_room', '/choose-room'),
      ('22_search_device', '/search'),
      ('23_device_found', '/found'),
      ('25_notifications', '/notifications'),
      ('26_invitations', '/invitations'),
      ('27_chatbot', '/assistant'),
      ('28_chat', '/chat'),
      ('29_chat_draft', '/chat-draft'),
      ('30_profile', '/profile'),
      ('32_edit_profile', '/edit-profile'),
      ('33_settings', '/settings'),
      ('35_notification_settings', '/notification-settings'),
      ('36_members', '/members'),
      ('37_language', '/language'),
      ('38_help_center', '/help'),
      ('39_about_us', '/about'),
    ];
    for (final theme in ['light', 'dark']) {
      store.dark = theme == 'dark';
      await store.changed();
      for (final page in pages) {
        if (!wanted(page.$1)) continue;
        await open(page.$2);
        await shot('$theme/${page.$1}');
      }
      await open('/verify');
      showTerms(nav.currentContext!);
      await shot('$theme/08_terms_popup');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await open('/rooms');
      roomDialog(nav.currentContext!);
      await shot('$theme/11_add_another_room');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      roomDialog(nav.currentContext!, existing: 'Kitchen');
      await shot('$theme/12_edit_room');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      store.lampMode = 'Color';
      await store.changed();
      await open('/lamp');
      await shot('$theme/18_lamp_color');
      store.lampMode = 'Warm';
      await store.changed();
      await open('/found');
      showAdded(nav.currentContext!);
      await shot('$theme/24_device_added');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await open('/profile');
      showAccounts(nav.currentContext!);
      await shot('$theme/31_switch_account');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await open('/settings');
      showLogout(nav.currentContext!);
      await shot('$theme/34_logout_popup');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
    }
    if (captureOnly) {
      store.restore(original);
      store.signedIn = true;
      await store.changed();
      await open('/home');
      return;
    }
    store.dark = false;
    await store.changed();
    await open('/home');
    final wasOn = store.devices.first.on;
    await tester.tap(find.byTooltip('Power Smart Lamp'));
    await tester.pumpAndSettle();
    expect(store.devices.first.on, !wasOn);
    await tester.tap(find.text('Smart Lamp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Romantic'));
    await tester.pumpAndSettle();
    expect(store.lampMode, 'Romantic');
    await tester.drag(find.byType(Slider).first, const Offset(55, 0));
    await tester.pumpAndSettle();
    expect(store.intensity, greaterThan(55));
    await open('/ac');
    await tester.tap(find.text('Fan'));
    await tester.pumpAndSettle();
    expect(store.acMode, 'Fan');
    await tester.drag(find.byType(Slider).first, const Offset(-45, 0));
    await tester.pumpAndSettle();
    expect(store.temperature, lessThan(24));
    await open('/choose-room');
    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Press power button 5 Seconds'), findsOneWidget);
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(find.text('Device found...'), findsOneWidget);
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(find.text('Device Added to\n“Kitchen”'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(store.devices.any((d) => d.id == 'added-tv-Kitchen'), true);
    await store.changed();
    final restored = await HomeStore.load();
    expect(restored.room, 'Kitchen');
    expect(restored.lampMode, 'Romantic');
    expect(restored.intensity, store.intensity);
    expect(restored.devices.any((d) => d.id == 'added-tv-Kitchen'), true);
    await open('/chat');
    await tester.enterText(find.byType(TextField), 'How can I save energy?');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.textContaining('compare monthly usage'), findsOneWidget);
    for (final size in [const Size(390, 844), const Size(360, 800)]) {
      for (final dark in [false, true]) {
        for (final route in routes) {
          debugPrint('Layout $route $size dark=$dark');
          await tester.pumpWidget(
            HomeScope(
              store: store,
              child: MaterialApp(
                theme: appTheme(dark),
                home: Builder(
                  builder: (ctx) => Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: MediaQuery(
                        data: MediaQuery.of(ctx).copyWith(size: size),
                        child: pageFor(route),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$route $size dark=$dark',
          );
        }
      }
    }
    store.restore(original);
    store.signedIn = true;
    await store.changed();
    await tester.pumpWidget(SuperSmartApp(store: store, initialRoute: '/home'));
    await tester.pumpAndSettle();
  });
}
