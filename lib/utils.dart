import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

Future<NLatLng> getCurrentPosition() async {
  final position = await Geolocator.getCurrentPosition();
  return NLatLng(position.latitude, position.longitude);
}

// 알림 팝업 (showDialog) 메세지를 받아서 다이얼로그 창을 띄워주는 함수
void showMessageDialog(
    BuildContext context, String message, void Function()? onConfirm) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: onConfirm,
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}
