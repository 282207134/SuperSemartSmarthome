import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartDevice {
  SmartDevice(this.id, this.name, this.room, this.kind, {this.on = true});
  final String id, name, room, kind;
  bool on;
  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'room': room,
    'kind': kind,
    'on': on,
  };
  factory SmartDevice.fromJson(Map<String, dynamic> j) =>
      SmartDevice(j['id'], j['name'], j['room'], j['kind'], on: j['on']);
}

/// Local demo repository. Device operations never connect to real hardware.
class HomeStore extends ChangeNotifier {
  HomeStore(this.prefs);
  final SharedPreferences prefs;
  static const storageKey = 'supersemart.v1';
  bool dark = false,
      signedIn = false,
      remote = true,
      editing = true,
      addMembers = false;
  bool push = true, temperatureAlerts = true, sound = false;
  String owner = 'Jakob Bergson',
      home = 'Jakob Home',
      email = 'jakobbergson@gmail.com';
  String country = 'United States',
      city = 'San Diego',
      room = 'Living Room',
      language = 'English (US)';
  String lampMode = 'Warm', acMode = 'Cooling';
  double intensity = 55, temperature = 24;
  int timer = 7;
  bool scenes = true, fastSwing = true, invitationAccepted = false;
  String from = '11:00 AM', to = '19:00 PM';
  List<String> rooms = ['Living Room', 'Bedroom', 'Kitchen'];
  List<String> members = [
    'Jakob Bergson',
    'Terry Saris',
    'Jaxson Stanton',
    'Ryan Korsgaard',
  ];
  List<SmartDevice> devices = [
    SmartDevice('lamp', 'Smart Lamp', 'Living Room', 'lamp'),
    SmartDevice('speaker', 'Speaker', 'Living Room', 'speaker'),
    SmartDevice('ac', 'Air Conditioner', 'Living Room', 'ac'),
    SmartDevice('tv', 'Smart TV', 'Living Room', 'tv', on: false),
    SmartDevice('kitchen-lamp', 'Kitchen Light', 'Kitchen', 'lamp'),
    SmartDevice('bedroom-ac', 'Air Conditioner', 'Bedroom', 'ac'),
  ];
  String? saveError;
  static Future<HomeStore> load() async {
    final s = HomeStore(await SharedPreferences.getInstance());
    final raw = s.prefs.getString(storageKey);
    if (raw != null) {
      try {
        s.restore(jsonDecode(raw) as Map<String, dynamic>);
      } on FormatException {
        s.saveError = 'Saved data could not be read. Defaults restored.';
      } on TypeError {
        s.saveError = 'Saved data was incompatible. Defaults restored.';
      }
    }
    return s;
  }

  void restore(Map<String, dynamic> j) {
    dark = j['dark'] ?? dark;
    signedIn = j['signedIn'] ?? signedIn;
    owner = j['owner'] ?? owner;
    home = j['home'] ?? home;
    email = j['email'] ?? email;
    country = j['country'] ?? country;
    city = j['city'] ?? city;
    rooms = List<String>.from(j['rooms'] ?? rooms);
    room = j['room'] ?? room;
    language = j['language'] ?? language;
    lampMode = j['lampMode'] ?? lampMode;
    acMode = j['acMode'] ?? acMode;
    intensity = ((j['intensity'] ?? intensity) as num).toDouble().clamp(0, 100);
    temperature = ((j['temperature'] ?? temperature) as num).toDouble().clamp(
      16,
      30,
    );
    remote = j['remote'] ?? remote;
    editing = j['editing'] ?? editing;
    addMembers = j['addMembers'] ?? addMembers;
    push = j['push'] ?? push;
    temperatureAlerts = j['temperatureAlerts'] ?? temperatureAlerts;
    sound = j['sound'] ?? sound;
    from = j['from'] ?? from;
    to = j['to'] ?? to;
    timer = j['timer'] ?? timer;
    scenes = j['scenes'] ?? scenes;
    fastSwing = j['fastSwing'] ?? fastSwing;
    invitationAccepted = j['invitationAccepted'] ?? invitationAccepted;
    members = List<String>.from(j['members'] ?? members);
    if (j['devices'] != null) {
      devices = (j['devices'] as List)
          .map((d) => SmartDevice.fromJson(d))
          .toList();
    }
    if (!rooms.contains(room) && rooms.isNotEmpty) room = rooms.first;
  }

  Map<String, dynamic> toJson() => {
    'dark': dark,
    'signedIn': signedIn,
    'owner': owner,
    'home': home,
    'email': email,
    'country': country,
    'city': city,
    'rooms': rooms,
    'room': room,
    'language': language,
    'lampMode': lampMode,
    'acMode': acMode,
    'intensity': intensity,
    'temperature': temperature,
    'remote': remote,
    'editing': editing,
    'addMembers': addMembers,
    'push': push,
    'temperatureAlerts': temperatureAlerts,
    'sound': sound,
    'from': from,
    'to': to,
    'timer': timer,
    'scenes': scenes,
    'fastSwing': fastSwing,
    'invitationAccepted': invitationAccepted,
    'members': members,
    'devices': devices.map((d) => d.toJson()).toList(),
  };
  Future<void> changed() async {
    notifyListeners();
    try {
      saveError = await prefs.setString(storageKey, jsonEncode(toJson()))
          ? null
          : 'Changes could not be saved.';
    } catch (_) {
      saveError = 'Changes could not be saved. Please try again.';
    }
    notifyListeners();
  }

  Future<void> toggle(SmartDevice d) {
    d.on = !d.on;
    return changed();
  }

  Future<void> addRoom(String name, {String? replacing}) async {
    final value = name.trim();
    if (value.isEmpty || (rooms.contains(value) && replacing != value)) return;
    if (replacing != null) {
      final index = rooms.indexOf(replacing);
      if (index < 0) return;
      rooms[index] = value;
      devices = devices
          .map(
            (d) => d.room == replacing
                ? SmartDevice(d.id, d.name, value, d.kind, on: d.on)
                : d,
          )
          .toList();
    } else {
      rooms.add(value);
    }
    room = value;
    await changed();
  }

  Future<void> addDevice() async {
    final id = 'added-tv-$room';
    if (!devices.any((d) => d.id == id)) {
      devices.add(SmartDevice(id, 'Samsung UA55 4AC', room, 'tv'));
    }
    await changed();
  }
}

class HomeScope extends InheritedNotifier<HomeStore> {
  const HomeScope({super.key, required HomeStore store, required super.child})
    : super(notifier: store);
  static HomeStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeScope>()!.notifier!;
}
