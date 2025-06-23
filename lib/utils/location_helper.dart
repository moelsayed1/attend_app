import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  static bool isInCompanyArea(Position position, double companyLat, double companyLng, double radiusMeters) {
    double distance = Geolocator.distanceBetween(
      position.latitude, position.longitude, companyLat, companyLng,
    );
    return distance <= radiusMeters;
  }
}