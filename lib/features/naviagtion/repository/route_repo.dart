import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteRepository {
  // tmap 보행자 경로 찾기 API
  final Dio _dio = Dio();
  final String _baseUrl = "https://apis.openapi.sk.com/tmap/routes/pedestrian";

  Future<Response> getPedestrianRoute({
    required NLatLng start,
    required NLatLng end,
  }) async {
    final String appKey = dotenv.env['SK_OPEN_API_KEY']!;
    try {
      final Response response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'AppKey': appKey,
          },
        ),
        data: {
          "version": "1",
          "startX": start.longitude,
          "startY": start.latitude,
          "endX": end.longitude,
          "endY": end.latitude,
          "startName": Uri.encodeComponent("출발지"),
          "endName": Uri.encodeComponent("도착"),
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

final routeRepo = Provider((ref) => RouteRepository());
