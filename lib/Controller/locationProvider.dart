import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _locationBox = "current_location_box";

const String _cityKey = "city";
const String _localityKey = "locality";
const String _addressKey = "address";

final locationProvider =
StateNotifierProvider<LocationNotifier, LocationState>(
      (ref) => LocationNotifier(),
);

class LocationState {
  final String city;
  final String locality;
  final String address;

  const LocationState({
    this.city = "",
    this.locality = "",
    this.address = "",
  });

  LocationState copyWith({
    String? city,
    String? locality,
    String? address,
  }) {
    return LocationState(
      city: city ?? this.city,
      locality: locality ?? this.locality,
      address: address ?? this.address,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  Future<void> load() async {
    final box = await Hive.openBox(_locationBox);

    state = LocationState(
      city: box.get(_cityKey, defaultValue: ""),
      locality: box.get(_localityKey, defaultValue: ""),
      address: box.get(_addressKey, defaultValue: ""),
    );
  }

  Future<void> save({
    required String city,
    required String locality,
    required String address,
  }) async {
    final box = await Hive.openBox(_locationBox);

    await box.put(_cityKey, city);
    await box.put(_localityKey, locality);
    await box.put(_addressKey, address);

    state = LocationState(
      city: city,
      locality: locality,
      address: address,
    );
  }

  Future<void> clear() async {
    final box = await Hive.openBox(_locationBox);

    await box.clear();

    state = const LocationState();
  }
}