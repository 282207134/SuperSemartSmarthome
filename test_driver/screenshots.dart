import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    final screenshots = data?['screenshots'] as List<dynamic>? ?? [];
    for (final raw in screenshots) {
      final entry = raw as Map<String, dynamic>;
      final file = File('docs/screenshots/${entry['screenshotName']}.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes((entry['bytes'] as List).cast<int>());
    }
    final total = ['light', 'dark'].fold<int>(
      0,
      (sum, theme) =>
          sum +
          Directory('docs/screenshots/$theme')
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.png'))
              .length,
    );
    await File('docs/screenshots/capture-summary.txt').writeAsString(
      'Latest run: ${screenshots.length} captures. Total: $total Flutter screenshots on existing Android emulator.\n',
    );
  },
);
