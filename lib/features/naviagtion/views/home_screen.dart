import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';
import 'package:wheretorun/features/naviagtion/models/route_line.dart';
import 'package:wheretorun/features/naviagtion/services/running_service.dart';
import 'package:wheretorun/features/naviagtion/view_models/route_view_model.dart';
import 'package:wheretorun/features/naviagtion/widgets/location_controller.dart';
import 'package:wheretorun/utils/position_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  NLatLng? _initialPosition;
  NLatLng? _destination;
  late final NaverMapController _mapController;
  late final AudioPlayer _audioPlayer;
  late final RunningService _runningService;

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
    await checkLocationPermission();
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
    });
    final marker = NMarker(id: 'destination', position: _destination!);
    _mapController.addOverlay(marker);
  }

  void _fetchRoute() {
    if (_destination == null) {
      return;
    }
    ref.read(routeProvider.notifier).fetchRoute(
          start: _initialPosition!,
          end: _destination!,
        );
  }

  void _onButtonPressed() async {
    await _audioPlayer.resume();
    Future.delayed(const Duration(milliseconds: 100), () {
      _audioPlayer.pause();
    });
    await _audioPlayer.seek(const Duration());
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

  void _clearRouteLines() {
    _mapController.clearOverlays(
      type: NOverlayType.polylineOverlay,
    );
  }

  void startRunning() {
    _runningService.start();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    final routeData = routeState.value!;
    if (routeState is AsyncData<RouteData> &&
        routeState.value.routeLines.isNotEmpty) {
      _runningService.routeData = routeState.value;
      _clearRouteLines();
      _drawRouteLines(routeState.value.routeLines);
    } else if (routeState is AsyncError) {
      final error = routeState.error;
      final stack = routeState.stackTrace;
      log("Error: $error", stackTrace: stack);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("네이버 지도"),
      ),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: _initialPosition!,
                      zoom: 16,
                    ),
                  ),
                  onMapReady: _onMapReady,
                  onMapTapped: _onMapTapped,
                ),
                ElevatedButton(
                  onPressed: _onButtonPressed,
                  child: const Text("비프음 재생"),
                ),
                if (_destination != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        //달리기 시작 버튼
                        ElevatedButton(
                          onPressed: startRunning,
                          child: const Text("달리기 시작"),
                        ),
                        // 경로생성 버튼
                        ElevatedButton(
                          onPressed: _fetchRoute,
                          child: const Text("경로 생성"),
                        ),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text("목적지"),
                                Text("위도: ${_destination!.latitude}"),
                                Text("경도: ${_destination!.longitude}"),
                                Text(
                                    "거리: ${_initialPosition!.distanceTo(_destination!).toStringAsFixed(2)}m"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: LocationController(
                    onUp: _runningService.moveToUp,
                    onDown: _runningService.moveToDown,
                    onLeft: _runningService.moveToLeft,
                    onRight: _runningService.moveToRight,
                  ),
                ),
              ],
            ),
    );
  }
}
