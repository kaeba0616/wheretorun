import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheretorun/constants/gaps.dart';
import 'package:wheretorun/features/common/widgets/start_button.dart';

class HomeButtonContainer extends ConsumerWidget {
  final VoidCallback onStartTap;
  final VoidCallback onExitTap;

  const HomeButtonContainer({
    super.key,
    required this.onStartTap,
    required this.onExitTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Gaps.v14,
        HomeButton(
          text: "Start running",
          onTap: onStartTap,
        ),
        Gaps.v14,
        HomeButton(
          text: "Exit",
          onTap: onExitTap,
        ),
      ],
    );
  }
}
