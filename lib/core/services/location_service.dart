import 'package:geolocator/geolocator.dart';

enum LocationOutcome { granted, denied, deniedForever, serviceDisabled, failed }

class LocationResult {
  const LocationResult({required this.outcome, this.position});

  final LocationOutcome outcome;
  final Position? position;

  bool get hasPosition => position != null;

  String get message => switch (outcome) {
    LocationOutcome.granted => 'Using your current location.',
    LocationOutcome.denied =>
      'Location is off, so this list is for the default area. Allow location '
          'to see what is actually nearest to you.',
    LocationOutcome.deniedForever =>
      'Location is blocked for MedGuardian. You can turn it back on in system '
          'settings.',
    LocationOutcome.serviceDisabled =>
      'Location services are switched off on this device, so distances are '
          'estimates for the default area.',
    LocationOutcome.failed =>
      'Could not read your location, showing the default area instead.',
  };
}

class LocationService {
  const LocationService();

  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(outcome: LocationOutcome.serviceDisabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(outcome: LocationOutcome.deniedForever);
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult(outcome: LocationOutcome.denied);
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return LocationResult(
        outcome: LocationOutcome.granted,
        position: position,
      );
    } catch (_) {
      return const LocationResult(outcome: LocationOutcome.failed);
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
