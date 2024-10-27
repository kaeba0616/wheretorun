import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';
import 'package:wheretorun/features/naviagtion/view_models/route_view_model.dart';

enum ReadyState { currentPosition, controller }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late NLatLng _currentPosition;
  late NaverMapController _controller;
  NLatLng? _destination;

  final Map<ReadyState, bool> _isReady = {
    ReadyState.currentPosition: false,
    ReadyState.controller: false,
  };

  void _setReady(ReadyState state, bool value) {
    setState(() {
      _isReady[state] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    await _requestPermission();
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = NLatLng(position.latitude, position.longitude);
      });
      _setReady(ReadyState.currentPosition, true);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    _setReady(ReadyState.controller, true);
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
    _controller.addOverlay(marker);
  }

  void _fetchRoute() {
    if (_destination == null) {
      return;
    }
    ref.read(routeProvider.notifier).fetchRoute(
          start: _currentPosition,
          end: _destination!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    // 로드된 경로 데이터를 오버레이로 추가
    if (routeState is AsyncData<RouteData> &&
        _isReady[ReadyState.controller] == true) {
      print(routeState.value.routeLines);
      for (var routeLine in routeState.value.routeLines) {
        final polyline = NPolylineOverlay(
          id: 'route_line_${routeLine.hashCode}',
          coords: routeLine.positions,
          color: Colors.blue,
          width: 5,
        );
        _controller.addOverlay(polyline);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("네이버 지도"),
      ),
      body: _isReady[ReadyState.currentPosition] == false
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: _currentPosition,
                      zoom: 18,
                    ),
                  ),
                  onMapReady: _onMapReady,
                  onMapTapped: _onMapTapped,
                ),
                if (_destination != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
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
                                    "거리: ${_currentPosition.distanceTo(_destination!).toStringAsFixed(2)}m"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
