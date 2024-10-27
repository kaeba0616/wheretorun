import 'package:flutter_naver_map/flutter_naver_map.dart';

class RouteData {
  final int totalDistance;
  final List<RoutePoint> routePoints;
  final List<RouteLine> routeLines;

  RouteData({
    required this.totalDistance,
    required this.routePoints,
    required this.routeLines,
  });

  RouteData.empty()
      : totalDistance = 0,
        routePoints = [],
        routeLines = [];

  factory RouteData.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as List<dynamic>;
    int totalDistance = 0;
    final points = <RoutePoint>[];
    final lines = <RouteLine>[];

    for (final feature in features) {
      final geometry = feature['geometry'];
      final type = geometry['type'];
      final properties = feature['properties'];

      const totalDistance = 0;

      if (type == "Point") {
        points.add(RoutePoint(
          position: NLatLng(
            geometry['coordinates'][1],
            geometry['coordinates'][0],
          ),
          type: PointType.fromString(properties['pointType']),
        ));
      } else if (type == "LineString") {
        lines.add(RouteLine(
          positions: (geometry['coordinates'] as List<dynamic>)
              .map((coord) =>
                  NLatLng(coord[1], coord[0])) // NaverMap uses lat, lng
              .toList(),
          distance: properties['distance'] as int,
        ));
      }
    }

    return RouteData(
      totalDistance: totalDistance,
      routePoints: points,
      routeLines: lines,
    );
  }
}

class RouteLine {
  final List<NLatLng> positions;
  final int distance;

  RouteLine({
    required this.positions,
    required this.distance,
  });
}

class RoutePoint {
  final NLatLng position;
  final PointType type;

  RoutePoint({
    required this.position,
    required this.type,
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
