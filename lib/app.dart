import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/home_store.dart';
import 'core/theme.dart';
import 'features/assistant.dart';
import 'features/dashboard.dart';
import 'features/device_control.dart';
import 'features/notifications.dart';
import 'features/onboarding.dart';
import 'features/profile.dart';
import 'features/setup.dart';

/// A single route table shared by the app, widget tests and screenshot tour.
Widget pageFor(String route) => switch (route) {
  '/splash' => const WelcomePage(splash: true),
  '/welcome' => const WelcomePage(),
  '/sign-up' => const AuthPage(mode: 'sign-up'),
  '/sign-in' => const AuthPage(mode: 'sign-in'),
  '/forgot' => const AuthPage(mode: 'forgot'),
  '/verify' => const AuthPage(mode: 'verify'),
  '/reset' => const AuthPage(mode: 'reset'),
  '/add-house' => const HousePage(),
  '/edit-profile' => const HousePage(edit: true),
  '/rooms' => const RoomsPage(),
  '/choose-room' => const RoomsPage(choose: true),
  '/setup-device' => const PairingPage(wizard: true),
  '/search-setup' => const PairingPage(stage: 1, wizard: true),
  '/found-setup' => const PairingPage(stage: 2, wizard: true),
  '/search' => const PairingPage(stage: 1),
  '/found' => const PairingPage(stage: 2),
  '/home' => const Dashboard(),
  '/lamp' => const DevicePage(),
  '/ac' => const DevicePage(ac: true),
  '/energy' => const EnergyPage(),
  '/notifications' => const NotificationsPage(),
  '/invitations' => const NotificationsPage(kitchen: true),
  '/assistant' => const AssistantPage(),
  '/chat' => const ChatPage(),
  '/chat-draft' => const ChatPage(draft: true),
  '/profile' => const ProfilePage(),
  '/settings' => const PreferencesPage(kind: 'settings'),
  '/notification-settings' => const PreferencesPage(
    kind: 'notification-settings',
  ),
  '/members' => const PreferencesPage(kind: 'members'),
  '/language' => const PreferencesPage(kind: 'language'),
  '/help' => const HelpPage(),
  '/about' => const PreferencesPage(kind: 'about'),
  _ when route.startsWith('/lamp/') => DevicePage(deviceId: route.substring(6)),
  _ when route.startsWith('/ac/') => DevicePage(
    ac: true,
    deviceId: route.substring(4),
  ),
  _ when route.startsWith('/device/') => DevicePage(
    deviceId: route.substring(8),
  ),
  _ => const Dashboard(),
};

class SuperSmartApp extends StatelessWidget {
  const SuperSmartApp({
    super.key,
    required this.store,
    this.initialRoute,
    this.navigatorKey,
  });
  final HomeStore store;
  final String? initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context) => HomeScope(
    store: store,
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'SuperSemart',
        debugShowCheckedModeBanner: false,
        theme: appTheme(false),
        darkTheme: appTheme(true),
        themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
        navigatorKey: navigatorKey,
        initialRoute: initialRoute ?? (store.signedIn ? '/home' : '/welcome'),
        onGenerateInitialRoutes: (name) => [
          MaterialPageRoute(
            builder: (_) => pageFor(name),
            settings: RouteSettings(name: name),
          ),
        ],
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => pageFor(settings.name ?? '/home'),
          settings: settings,
        ),
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: store.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: child!,
        ),
      ),
    ),
  );
}
