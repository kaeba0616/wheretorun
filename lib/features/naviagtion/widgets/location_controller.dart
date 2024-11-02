import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wheretorun/features/naviagtion/services/running_service.dart';

class LocationController extends StatelessWidget {
  final RunningService runningService;

  const LocationController({
    super.key,
    required this.runningService,
  });

  Widget _buildArrowButton(double angle, VoidCallback onPressed) {
    return Transform.rotate(
      angle: angle,
      child: IconButton(
        icon: const Icon(Icons.arrow_drop_up),
        iconSize: 48,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 좌측 상단 화살표 버튼
            _buildArrowButton(-pi / 4, runningService.moveUpLeft),
            // 위쪽 화살표 버튼
            _buildArrowButton(0, runningService.moveUp),
            // 우측 상단 화살표 버튼
            _buildArrowButton(pi / 4, runningService.moveUpRight),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 좌측 화살표 버튼
            _buildArrowButton(-pi / 2, runningService.moveLeft),
            // 정지 버튼
            const SizedBox(
              width: 70,
              height: 48,
            ),
            // 우측 화살표 버튼
            _buildArrowButton(pi / 2, runningService.moveRight),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 좌측 하단 화살표 버튼
            _buildArrowButton(-3 * pi / 4, runningService.moveDownLeft),
            // 아래쪽 화살표 버튼
            _buildArrowButton(pi, runningService.moveDown),
            // 우측 하단 화살표 버튼
            _buildArrowButton(3 * pi / 4, runningService.moveDownRight),
          ],
        ),
      ],
    );
  }
}
