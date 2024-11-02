import 'dart:async';
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
  final double arrivalThreshold = 10.0;

  int _nextPointIndex = 0;
  final ValueNotifier<int> remainDistanceNotifier = ValueNotifier(0);
  final ValueNotifier<int> runningTimeNotifier = ValueNotifier(0);
  final ValueNotifier<double> nextPointAngleNotifier = ValueNotifier(0.0);

  Timer? _timer;

  final List<NCircleOverlay> _circleOverlays = [];

  set audioPlayer(AudioPlayer player) {
    _audioPlayer = player;
  }

  set routeData(RouteData route) {
    _routeData = route;
    remainDistanceNotifier.value = route.totalDistance;

    for (final point in route.routePoints) {
      final circleOverlay = NCircleOverlay(
        id: point.position.toString(),
        center: point.position,
        radius: 5,
        color: Colors.red,
      );
      _circleOverlays.add(circleOverlay);
    }
  }

  set currentPosition(NLatLng position) {
    _currentPosition = position;
  }

  set mapController(NaverMapController controller) {
    _mapController = controller;
  }

  void start() async {
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

    _startTimer();
    _setVisitedPoint(-1);
    await _updateCurrentPosition();
    await _rotateCameraNextPoint(0);
    _updateNextPointAngle();
  }

  void _setVisitedPoint(int index) {
    // 지나간 경유지를 표시하기 위해, 지나간 경유지는 초록색으로 표시
    if (index >= 0) _drawCircleOverlay(index, Colors.green);
    if (index + 1 < _circleOverlays.length) {
      _drawCircleOverlay(index + 1, Colors.red);
    }
  }

  Future<void> _rotateCameraNextPoint(int index) async {
    double angle = 0;
    final nextPoint = _routeData.routePoints[index];
    if (index == 0) {
      angle = _calculateBearing(_currentPosition, nextPoint.position);
    } else {
      final prevPoint = _routeData.routePoints[index - 1];
      angle = _calculateBearing(prevPoint.position, nextPoint.position);
    }
    await _mapController.updateCamera(
      NCameraUpdate.withParams(bearing: angle),
    );
  }

  void _drawCircleOverlay(int index, Color color) {
    final circleOverlay = _circleOverlays[index];

    final newCircleOverlay = NCircleOverlay(
      id: "circle_$index",
      center: circleOverlay.center,
      radius: circleOverlay.radius,
      color: color,
    );
    _circleOverlays[index] = newCircleOverlay;
    _mapController.addOverlay(newCircleOverlay);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      runningTimeNotifier.value++;
    });
  }

  void _updateNextPointAngle() {
    if (_nextPointIndex + 1 >= _routeData.routePoints.length) {
      return;
    }
    if (_nextPointIndex < _routeData.routePoints.length) {
      final nextPoint = _routeData.routePoints[_nextPointIndex];
      final angle1 = _calculateBearing(_currentPosition, nextPoint.position);
      final angle2 = _calculateBearing(
        nextPoint.position,
        _routeData.routePoints[_nextPointIndex + 1].position,
      );
      nextPointAngleNotifier.value = angle2 - angle1;
      print("angle: ${nextPointAngleNotifier.value}");
    }
  }

  void pause() {
    // 타이머 일시정지
    _timer?.cancel();
  }

  void resume() {
    // 타이머 재개
    _startTimer();
  }

  void stop() {
    // 1. positionStream 구독 해제
    // 2. audioPlayer 정지
    // 3. 타이머 정지
    _timer?.cancel();
  }

  Future<void> _updateCurrentPosition() async {
    // 현재 위치를 업데이트하고, 지도에 위치 오버레이를 업데이트
    final NLocationOverlay locationOverlay =
        _mapController.getLocationOverlay();
    locationOverlay.setPosition(_currentPosition);
    await _mapController.updateCamera(
      NCameraUpdate.withParams(
        target: _currentPosition,
        zoom: 16,
      ),
    );
  }

  void _onArriveNextPoint() {
    _setVisitedPoint(_nextPointIndex);

    // 카메라 각도를 다음 경유지 방향으로 변경
    _nextPointIndex++;
    _rotateCameraNextPoint(_nextPointIndex);
    _updateNextPointAngle();
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
    _updateNextPointAngle();

    if (distance <= arrivalThreshold) {
      _onArriveNextPoint();
      // audioPlayer.play("경유지 도착 알림음 경로");
      return;
    }
    if (distance <= alertDistance) {
      // _playDirectionalAlert(nextPoint);
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
  void moveUpRight() => _move(step, step);
  void moveUpLeft() => _move(step, -step);
  void moveDownRight() => _move(-step, step);
  void moveDownLeft() => _move(-step, -step);
}
