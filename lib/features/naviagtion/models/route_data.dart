import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:wheretorun/features/naviagtion/models/route_line.dart';
import 'package:wheretorun/features/naviagtion/models/route_point.dart';

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
