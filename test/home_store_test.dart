import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_smart_home/core/home_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'device state, controls, profile and preferences survive reload',
    () async {
      final s = await HomeStore.load();
      await s.toggle(s.devices.first);
      s.intensity = 83;
      s.temperature = 21;
      s.dark = true;
      s.owner = 'Alex';
      s.language = 'Japanese';
      s.remote = false;
      await s.changed();
      final restored = await HomeStore.load();
      expect(restored.devices.first.on, false);
      expect(restored.intensity, 83);
      expect(restored.temperature, 21);
      expect(restored.dark, true);
      expect(restored.owner, 'Alex');
      expect(restored.language, 'Japanese');
      expect(restored.remote, false);
    },
  );
  test(
    'renaming a room retains associated devices and prevents duplicates',
    () async {
      final s = await HomeStore.load();
      await s.addRoom('Lounge', replacing: 'Living Room');
      expect(s.devices.where((d) => d.room == 'Lounge').length, 4);
      expect(s.room, 'Lounge');
      await s.addRoom('Lounge');
      await s.addRoom('   ');
      expect(s.rooms.length, 3);
      final restored = await HomeStore.load();
      expect(restored.rooms.first, 'Lounge');
    },
  );
  test('pairing is idempotent within a room', () async {
    final s = await HomeStore.load();
    await s.addDevice();
    await s.addDevice();
    expect(s.devices.where((d) => d.id == 'added-tv-Living Room').length, 1);
    s.room = 'Kitchen';
    await s.addDevice();
    expect(s.devices.where((d) => d.id.startsWith('added-tv-')).length, 2);
  });
  test('invalid saved data falls back without preventing startup', () async {
    SharedPreferences.setMockInitialValues({HomeStore.storageKey: '{broken'});
    final s = await HomeStore.load();
    expect(s.rooms, contains('Living Room'));
    expect(s.saveError, isNotNull);
  });
}
