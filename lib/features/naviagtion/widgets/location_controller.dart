import 'package:flutter/material.dart';

class LocationController extends StatelessWidget {
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  const LocationController({
    super.key,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 위쪽 화살표 버튼
          IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            iconSize: 48,
            onPressed: onUp,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 왼쪽 화살표 버튼
              IconButton(
                icon: const Icon(Icons.arrow_left),
                iconSize: 48,
                onPressed: onLeft,
              ),
              // 가운데 빈 공간 (방향 조작 시, 중앙을 기준으로 조작감을 주기 위해)
              const SizedBox(width: 48),
              // 오른쪽 화살표 버튼
              IconButton(
                icon: const Icon(Icons.arrow_right),
                iconSize: 48,
                onPressed: onRight,
              ),
            ],
          ),
          // 아래쪽 화살표 버튼
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 48,
            onPressed: onDown,
          ),
        ],
      ),
    );
  }
}
