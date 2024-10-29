import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:wheretorun/features/naviagtion/models/route_data.dart';

class RunningService {
  final AudioPlayer audioPlayer;
  final RouteData routeData;
  final NLatLng initialPosition;

  RunningService({
    required this.audioPlayer,
    required this.routeData,
    required this.initialPosition,
  });
}
