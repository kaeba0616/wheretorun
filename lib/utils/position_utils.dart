import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

Future<void> checkLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('위치 서비스가 비활성화되었습니다.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    final requestPermission = await Geolocator.requestPermission();
    if (requestPermission == LocationPermission.denied ||
        requestPermission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 필요합니다.');
    }
  }
}

Future<NLatLng> getCurrentPosition() async {
  final position = await Geolocator.getCurrentPosition();
  return NLatLng(position.latitude, position.longitude);
}
