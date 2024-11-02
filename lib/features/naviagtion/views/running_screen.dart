import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheretorun/features/naviagtion/models/route_line.dart';
import 'package:wheretorun/features/naviagtion/models/route_point.dart';
import 'package:wheretorun/features/naviagtion/services/running_service.dart';
import 'package:wheretorun/features/naviagtion/view_models/route_view_model.dart';
import 'package:wheretorun/features/naviagtion/widgets/location_controller.dart';
import 'package:wheretorun/utils.dart';

enum RunningState {
  initialPosition, // 초기 위치 설정 상태
  mapReady, // 지도 준비 상태
  selectDestination, // 도착지 선택 상태
  generateRoute, // 경로 생성 상태
  startRunning, // 달리기 시작 대기 상태
  running, // 달리기 중 상태
  finished, // 도착 및 완료 상태
}

class RunningScreen extends ConsumerStatefulWidget {
  static const String routeName = "RunningScreen";
  static const String routeUrl = "/running";
  const RunningScreen({super.key});

  @override
  ConsumerState<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends ConsumerState<RunningScreen> {
  NLatLng? _initialPosition;
  NLatLng? _destination;
  late final NaverMapController _mapController;
  late final AudioPlayer _audioPlayer;
  late final RunningService _runningService;

  // Running 상태를 관리하는 enum 변수
  RunningState _currentState = RunningState.initialPosition;

  @override
  void initState() {
    super.initState();
    _runningService = RunningService();
    _initPosition();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _initPosition() async {
    final position = await getCurrentPosition();
    setState(() {
      _initialPosition = position;
    });
    _runningService.currentPosition = position;
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSource(AssetSource("sounds/beep.mp3"));
    _runningService.audioPlayer = _audioPlayer;
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _runningService.mapController = controller;
    final NLocationOverlay locationOverlay = controller.getLocationOverlay();
    locationOverlay.setIsVisible(true);
  }

  void _onMapTapped(NPoint point, NLatLng position) {
    _setDestination(position);
  }

  void _setDestination(NLatLng position) {
    setState(() {
      _destination = position;
      _currentState = RunningState.generateRoute;
    });
    final marker = NMarker(id: 'destination', position: _destination!);
    _mapController.addOverlay(marker);
  }

  void _fetchRoute() async {
    if (_destination == null) return;

    await ref.read(routeProvider.notifier).fetchRoute(
          start: _initialPosition!,
          end: _destination!,
        );
    final routeData = ref.read(routeProvider).value!;
    _runningService.routeData = routeData;

    _clearRoute();
    _drawRouteLines(routeData.routeLines);
    _drawRoutePoints(routeData.routePoints);

    setState(() {
      _currentState = RunningState.startRunning;
    });
  }

  void _drawRoutePoints(List<RoutePoint> routePoints) {
    for (var routePoint in routePoints) {
      final circle = NCircleOverlay(
        id: "route_point_${routePoint.hashCode}",
        center: routePoint.position,
        radius: 5,
        outlineWidth: 2,
        outlineColor: Colors.black,
      );
      _mapController.addOverlay(circle);
    }
  }

  void _drawRouteLines(List<RouteLine> routeLines) {
    for (var routeLine in routeLines) {
      final polyline = NPolylineOverlay(
        id: 'route_line_${routeLine.hashCode}',
        coords: routeLine.positions,
        color: Colors.blue,
        width: 5,
      );
      _mapController.addOverlay(polyline);
    }
  }

  void _clearRoute() {
    _mapController.clearOverlays();
  }

  void startRunning() {
    _runningService.start();
    setState(() {
      _currentState = RunningState.running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Where to Run"),
      ),
      body: Stack(
        children: [
          _buildPopup(_currentState),
          _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: _initialPosition!,
                      zoom: 16,
                    ),
                  ),
                  onMapReady: _onMapReady,
                  onMapTapped: _onMapTapped,
                ),
          // 상태별로 다른 UI 구성
          if (_currentState == RunningState.generateRoute)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _fetchRoute,
                child: const Text("경로 생성"),
              ),
            ),
          if (_currentState == RunningState.startRunning)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: startRunning,
                child: const Text("달리기 시작"),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: LocationController(
              onUp: _currentState == RunningState.running
                  ? _runningService.moveUp
                  : null,
              onDown: _currentState == RunningState.running
                  ? _runningService.moveDown
                  : null,
              onLeft: _currentState == RunningState.running
                  ? _runningService.moveLeft
                  : null,
              onRight: _currentState == RunningState.running
                  ? _runningService.moveRight
                  : null,
            ),
          ),
          if (_currentState == RunningState.running)
            Positioned(
              bottom: 30,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder(
                    valueListenable: _runningService.remainDistanceNotifier,
                    builder: (context, value, child) {
                      return Text("남은 거리: ${value.toStringAsFixed(2)}m");
                    }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopup(RunningState state) {
    String message = "";
    log("state: $state");
    switch (state) {
      case RunningState.initialPosition:
        message = "초기 위치를 설정 중입니다.";
        break;
      case RunningState.mapReady:
        message = "지도 준비 중입니다.";
        break;
      case RunningState.selectDestination:
        message = "도착지를 선택해주세요.";
        break;
      case RunningState.generateRoute:
        message = "경로 생성 중입니다.";
        break;
      case RunningState.startRunning:
        message = "달리기 시작을 눌러주세요.";
        break;
      case RunningState.running:
        message = "달리기 중입니다.";
        break;
      case RunningState.finished:
        message = "도착했습니다.";
        break;
    }
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
