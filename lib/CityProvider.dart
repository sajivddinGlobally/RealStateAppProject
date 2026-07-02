import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Constant box name
const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

// Provider jo current city provide karega (reactive)
final currentCityProvider = StateProvider<String?>((ref) => null);

// Provider jo Hive se saved city load karega (future)
final savedCityProvider = FutureProvider<String?>((ref) async {
  final box = await Hive.openBox(_cityBoxName);
  return box.get(_cityKey) as String?;
});

// Function to save city in Hive
Future<void> saveCity(String city) async {
  final box = await Hive.openBox(_cityBoxName);
  await box.put(_cityKey, city);
}

// Optional: clear karne ke liye (logout ya reset ke time)
Future<void> clearSavedCity() async {
  final box = await Hive.openBox(_cityBoxName);
  await box.delete(_cityKey);
}