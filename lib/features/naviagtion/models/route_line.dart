import 'package:flutter_naver_map/flutter_naver_map.dart';

class RouteLine {
  final List<NLatLng> positions;
  final int distance;

  RouteLine({
    required this.positions,
    required this.distance,
  });
}
