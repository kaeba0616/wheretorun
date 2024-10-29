import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';

class RunningService {
  late final AudioPlayer audioPlayer;
  late final RouteData routeData;
  late NLatLng currentPosition;
  late NaverMapController mapController;

  RunningService();

  void _moveCameraToCurrentPosition() {
    final NLocationOverlay locationOverlay = mapController.getLocationOverlay();
    locationOverlay.setPosition(currentPosition);
  }

  void moveToRight() {
    // 오른쪽으로 이동
    currentPosition = NLatLng(
      currentPosition.latitude,
      currentPosition.longitude + 0.00005,
    );
    _moveCameraToCurrentPosition();
  }

  void moveToLeft() {
    // 왼쪽으로 이동
    currentPosition = NLatLng(
      currentPosition.latitude,
      currentPosition.longitude - 0.00005,
    );
    _moveCameraToCurrentPosition();
  }

  void moveToUp() {
    // 위로 이동
    currentPosition = NLatLng(
      currentPosition.latitude + 0.00005,
      currentPosition.longitude,
    );
    _moveCameraToCurrentPosition();
  }

  void moveToDown() {
    // 아래로 이동
    currentPosition = NLatLng(
      currentPosition.latitude - 0.00005,
      currentPosition.longitude,
    );
    _moveCameraToCurrentPosition();
  }

  // Stream
}
