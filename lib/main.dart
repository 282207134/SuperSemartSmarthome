import 'package:flutter/material.dart';

import 'app.dart';
import 'core/home_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SuperSmartApp(store: await HomeStore.load()));
}
