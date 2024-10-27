import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';
import 'package:wheretorun/features/naviagtion/repository/route_repo.dart';

class RouteViewModel extends AsyncNotifier<RouteData> {
  late final RouteRepository _repository;

  @override
  FutureOr<RouteData> build() {
    _repository = ref.read(routeRepo);
    return RouteData.empty();
  }

  Future<void> fetchRoute({
    required NLatLng start,
    required NLatLng end,
  }) async {
    state = const AsyncLoading();
    try {
      final response =
          await _repository.getPedestrianRoute(start: start, end: end);
      final routeData =
          RouteData.fromJson(response.data as Map<String, dynamic>);
      state = AsyncData(routeData);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final routeProvider = AsyncNotifierProvider<RouteViewModel, RouteData>(
  () => RouteViewModel(),
);
