import 'dart:math';
import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';
import 'package:wheretorun/features/naviagtion/models/route_point.dart';

class RunningService {
  late final AudioPlayer _audioPlayer;
  late RouteData _routeData;
  late NLatLng _currentPosition;
  late NaverMapController _mapController;
  final double step = 0.00005;
  final double alertDistance = 60.0;
  final double arrivalThreshold = 40.0;

  int _nextPointIndex = 1;
  final ValueNotifier<int> remainDistanceNotifier = ValueNotifier(0);

  set audioPlayer(AudioPlayer player) {
    _audioPlayer = player;
  }

  set routeData(RouteData route) {
    _routeData = route;
    remainDistanceNotifier.value = route.totalDistance;
  }

  set currentPosition(NLatLng position) {
    _currentPosition = position;
  }

  set mapController(NaverMapController controller) {
    _mapController = controller;
  }

  void start() {
    // 1. positionStream을 구독하여 위치 정보 업데이트 (임시로 우리는 move 함수로 위치를 이동시킴)

    // 2. routeData를 이용하여, 현재 위치와 다음 경유지 사이의 거리를 계산
    // 3. 알림 구역내로 들어왔으면, 다음 경유지의 방향에 따라 그 각도로, 알림음 방향을 조절하여 재생
    // 4. 경유지에 도착하면, 경유지 도착 알림음 재생 후, 다음 경유지 설정
    // 5. 도착지에 도착하면, 도착 알림음 재생 후, 종료

    // 1.번은 임시로 구현 했으므로, 2번부터 구현
    // 시작 알림음 재생
    // audioPlayer.play("시작알림음 경로");

    // 1. 시작점을 현재 위치로 설정
    // 2. 현재 위치를 positionStream을 통해 구독하여 위치 정보 업데이트 (임시로 우리는 move 함수로 위치를 이동시킴)
    // 3. 현재 위치와 그전 경유지 즉, 처음 시작할때는 시작점 사이의 거리를 계산 (지나온 거리라고 변수 만듬)
    // 4. 그전 경유지 즉, 처음 시작할떄는 시작점에서의 remainDistance와 지나온 거리를 빼서 남은 거리를 계산
    // 5. 다음 경유지에 도착시 remainDistance를 갱신
  }

  void _updateCurrentPosition() {
    // 현재 위치를 업데이트
    final NLocationOverlay locationOverlay =
        _mapController.getLocationOverlay();
    locationOverlay.setPosition(_currentPosition);
  }

  void _checkPointProximity() {
    // 현재 위치와 다음 경유지 사이의 거리를 계산
    // 경유지에 도착하면, 경유지 도착 알림음 재생 후, 다음 경유지 설정
    // 도착지에 도착하면, 도착 알림음 재생 후, 종료
    if (_nextPointIndex >= _routeData.routePoints.length) {
      // 도착지에 도착
      // audioPlayer.play("도착 알림음 경로");
      return;
    }
    final nextPoint = _routeData.routePoints[_nextPointIndex];
    final distance = _currentPosition.distanceTo(nextPoint.position).toInt();
    remainDistanceNotifier.value = nextPoint.remainDistance + distance;
    developer.log("Distance to the next point: $distance");
    if (distance <= arrivalThreshold) {
      developer.log(
          "Arrived at the next point: ${_routeData.routePoints[_nextPointIndex].position}");
      _nextPointIndex++;
      // audioPlayer.play("경유지 도착 알림음 경로");
      return;
    }
    if (distance <= alertDistance) {
      _playDirectionalAlert(nextPoint);
      developer.log("Alert at the next point: $_nextPointIndex");
      developer.log(
          "Alert at the next point: ${_routeData.routePoints[_nextPointIndex].position}");
    }
  }

  void _playDirectionalAlert(RoutePoint nextPoint) {
    // 다음 경유지의 방향에 따라 그 각도로, 알림음 방향을 조절하여 재생
    // 각도는 다음처럼 계산: 이전 점과 nextPoint, nextPoint와 다음 점, 두 선의 각도

    if (_nextPointIndex + 1 >= _routeData.routePoints.length) {
      return;
    }
    final prevPoint = _routeData.routePoints[_nextPointIndex - 1];
    final nextNextPoint = _routeData.routePoints[_nextPointIndex + 1];
    final bearing1 = _calculateBearing(prevPoint.position, nextPoint.position);
    final bearing2 =
        _calculateBearing(nextPoint.position, nextNextPoint.position);
    final angle = bearing1 - bearing2;

    _audioPlayer.setBalance(angle / 180);
    developer.log("angle: $angle");
    _audioPlayer.play(AssetSource("sounds/beep.mp3"));
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

  void _move(double distLat, double distLng) {
    currentPosition = NLatLng(
      _currentPosition.latitude + distLat,
      _currentPosition.longitude + distLng,
    );
    _updateCurrentPosition();
    _checkPointProximity();
  }

  void moveRight() => _move(0, step);
  void moveLeft() => _move(0, -step);
  void moveUp() => _move(step, 0);
  void moveDown() => _move(-step, 0);
}
