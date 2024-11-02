import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretorun/constants/sizes.dart';
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
  countdown, // 카운트 다운 상태
  running, // 달리기 중 상태
  paused, // 일시정지 상태
  finished, // 도착 및 완료 상태
}

Map<RunningState, String> stateMessage = {
  RunningState.initialPosition: "초기 위치를 설정 중입니다.",
  RunningState.mapReady: "지도 준비 중입니다.",
  RunningState.selectDestination: "도착지를 선택해주세요.",
  RunningState.generateRoute: "경로 생성 버튼을 눌러주세요.",
  RunningState.startRunning: "달리기 시작을 눌러주세요.",
  RunningState.running: "달리기 중입니다.",
  RunningState.paused: "일시정지 중입니다.",
  RunningState.finished: "달리기가 종료되었습니다.",
};

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

  // 초기 카운트 다운
  final ValueNotifier<int> _countdown = ValueNotifier(3);

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
    _countdown.dispose();
    super.dispose();
  }

  void _initPosition() async {
    final position = await getCurrentPosition();
    setState(() {
      _initialPosition = position;
      _currentState = RunningState.mapReady;
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
    setState(() {
      _currentState = RunningState.selectDestination;
    });
  }

  void _onMapTapped(NPoint point, NLatLng position) {
    if (_currentState == RunningState.selectDestination ||
        _currentState == RunningState.generateRoute) {
      _setDestination(position);
    }
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
    setState(() {
      _currentState = RunningState.countdown;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdown.value = 3;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown.value == 0) {
        timer.cancel();
        _runningService.start();
        setState(() {
          _currentState = RunningState.running;
        });
      } else {
        _countdown.value--;
      }
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
          // 테스트용 버튼

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
          _buildPopup(_currentState),

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
          if (_currentState == RunningState.countdown) _buildCountdown(),
          if (_currentState == RunningState.paused) ...[
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _runningService.resume();
                      setState(() {
                        _currentState = RunningState.running;
                      });
                    },
                    child: const Text("다시 시작"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // _runningService.stop();
                      setState(() {
                        _currentState = RunningState.finished;
                      });
                    },
                    child: const Text("달리기 종료"),
                  ),
                ],
              ),
            ),
          ],
          if (_currentState == RunningState.running) ...[
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: ValueListenableBuilder(
                  valueListenable: _runningService.cameraAngleNotifier,
                  builder: (context, angle, child) {
                    return Transform.rotate(
                      angle: -angle * pi / 180,
                      child: LocationController(
                        runningService: _runningService,
                      ),
                    );
                  },
                ),
              ),
            ),
            // 달리기 일시정지 버튼
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _runningService.pause();
                        setState(() {
                          _currentState = RunningState.paused;
                        });
                      },
                      child: const Text("일시정지"),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _runningService.isAlertingNotifier,
                      builder: (context, value, child) {
                        if (!value) {
                          return const SizedBox();
                        }
                        return ValueListenableBuilder<double>(
                          valueListenable:
                              _runningService.nextPointAngleNotifier,
                          builder: (context, angle, child) {
                            return Transform.rotate(
                              angle: angle * pi / 180, // 각도에 따라 회전 적용
                              child: const FaIcon(
                                FontAwesomeIcons.arrowUp,
                                color: Colors.red,
                                size: 60,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
          if (_currentState == RunningState.running ||
              _currentState == RunningState.paused) ...[
            Positioned(
              bottom: 16,
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
            // 달리기 타이머
            Positioned(
              bottom: 30,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder<int>(
                  valueListenable: _runningService.runningTimeNotifier,
                  builder: (context, time, child) {
                    final minutes = (time / 60).floor();
                    final seconds = time % 60;
                    return Text(
                      "달린 시간: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    );
                  },
                ),
              ),
            ),
          ],
          // 달리기 종료 후, 결과 출력 및 나가기 버튼
          if (_currentState == RunningState.finished) ...[
            // runningService에서 결과들을 가져와서 보여준다.
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("나가기"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder<int>(
        valueListenable: _countdown,
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size20,
              vertical: Sizes.size10,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value == 0 ? "달리기 시작!" : value.toString(),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopup(RunningState state) {
    String message = "";
    if (stateMessage.containsKey(state)) {
      message = stateMessage[state]!;
    }
    if (state == RunningState.running || state == RunningState.countdown) {
      return const SizedBox();
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
