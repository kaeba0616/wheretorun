import 'package:flutter_naver_map/flutter_naver_map.dart';

class RoutePoint {
  final NLatLng position;
  final PointType type;
  final int remainDistance;

  RoutePoint({
    required this.position,
    required this.type,
    required this.remainDistance,
  });
}

enum PointType {
  start,
  end,
  pass,
  pass1,
  pass2,
  pass3,
  pass4,
  pass5,
  general;

  static PointType fromString(String type) {
    switch (type) {
      case 'SP':
        return PointType.start;
      case 'EP':
        return PointType.end;
      case 'PP':
        return PointType.pass;
      case 'PP1':
        return PointType.pass1;
      case 'PP2':
        return PointType.pass2;
      case 'PP3':
        return PointType.pass3;
      case 'PP4':
        return PointType.pass4;
      case 'PP5':
        return PointType.pass5;
      case 'GP':
        return PointType.general;
      default:
        throw ArgumentError('Invalid point type: $type');
    }
  }
}
