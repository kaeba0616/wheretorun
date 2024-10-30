import 'dart:math';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';
import 'package:wheretorun/features/naviagtion/models/route_point.dart';

class RunningService {
  late final AudioPlayer audioPlayer;
  late RouteData routeData;
  late NLatLng currentPosition;
  late NaverMapController mapController;
  final double step = 0.00001;
  final double alertDistance = 20.0;
  final double arrivalThreshold = 10.0;
  int _nextPointIndex = 1;

  RunningService();

  void start() {
    // 1. positionStream을 구독하여 위치 정보 업데이트 (임시로 우리는 move 함수로 위치를 이동시킴)
    // 2. routeData를 이용하여, 현재 위치와 다음 경유지 사이의 거리를 계산
    // 3. 알림 구역내로 들어왔으면, 다음 경유지의 방향에 따라 그 각도로, 알림음 방향을 조절하여 재생
    // 4. 경유지에 도착하면, 경유지 도착 알림음 재생 후, 다음 경유지 설정
    // 5. 도착지에 도착하면, 도착 알림음 재생 후, 종료

    // 1.번은 임시로 구현 했으므로, 2번부터 구현
    // 시작 알림음 재생
    // audioPlayer.play("시작알림음 경로");
  }

  void _updateCurrentPosition() {
    // 현재 위치를 업데이트
    final NLocationOverlay locationOverlay = mapController.getLocationOverlay();
    locationOverlay.setPosition(currentPosition);
  }

  void _checkPointProximity() {
    // 현재 위치와 다음 경유지 사이의 거리를 계산
    // 경유지에 도착하면, 경유지 도착 알림음 재생 후, 다음 경유지 설정
    // 도착지에 도착하면, 도착 알림음 재생 후, 종료
    if (_nextPointIndex >= routeData.routePoints.length) {
      // 도착지에 도착
      // audioPlayer.play("도착 알림음 경로");
      return;
    }

    final nextPoint = routeData.routePoints[_nextPointIndex];
    final distance = currentPosition.distanceTo(nextPoint.position);
    developer.log("Distance to the next point: $distance");
    if (distance <= arrivalThreshold) {
      developer.log(
          "Arrived at the next point: ${routeData.routePoints[_nextPointIndex].position}");
      _nextPointIndex++;
      // audioPlayer.play("경유지 도착 알림음 경로");
      return;
    }

    if (distance <= alertDistance) {
      _playDirectionalAlert(nextPoint);
      developer.log("Alert at the next point: $_nextPointIndex");
      developer.log(
          "Alert at the next point: ${routeData.routePoints[_nextPointIndex].position}");
    }
  }

  void _playDirectionalAlert(RoutePoint nextPoint) {
    // 다음 경유지의 방향에 따라 그 각도로, 알림음 방향을 조절하여 재생
    // 각도는 다음처럼 계산: 이전 점과 nextPoint, nextPoint와 다음 점, 두 선의 각도

    final prevPoint = routeData.routePoints[_nextPointIndex - 1];
    final nextNextPoint = routeData.routePoints[_nextPointIndex + 1];
    final bearing1 = _calculateBearing(prevPoint.position, nextPoint.position);
    final bearing2 =
        _calculateBearing(nextPoint.position, nextNextPoint.position);
    final angle = bearing1 - bearing2;
    audioPlayer.setBalance(angle / 180);
    print("angle: $angle");
    audioPlayer.play(AssetSource("sounds/beep.mp3"));
  }

  double _calculateBearing(NLatLng from, NLatLng to) {
    // 두 점 사이의 각도크기 계산
    final lat1 = from.latitude;
    final lon1 = from.longitude;
    final lat2 = to.latitude;
    final lon2 = to.longitude;

    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    final angle = ((atan2(dlon, dlat) * 180) / pi + 360) % 360;

    return angle;
  }

  void move(double distLat, double distLng) {
    currentPosition = NLatLng(
      currentPosition.latitude + distLat,
      currentPosition.longitude + distLng,
    );
    _updateCurrentPosition();
    _checkPointProximity();
  }

  void moveToRight() {
    move(0, step);
  }

  void moveToLeft() {
    move(0, -step);
  }

  void moveToUp() {
    move(step, 0);
  }

  void moveToDown() {
    move(-step, 0);
  }
  // Stream
}
