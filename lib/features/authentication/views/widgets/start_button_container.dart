import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretorun/constants/gaps.dart';
import 'package:wheretorun/constants/sizes.dart';
import 'package:wheretorun/features/authentication/views/widgets/start_button.dart';

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
          icon: const FaIcon(
            FontAwesomeIcons.play,
            size: Sizes.size30,
          ),
          onTap: onStartTap,
        ),
        Gaps.v14,
        HomeButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowRightFromBracket,
            size: Sizes.size30,
          ),
          onTap: onExitTap,
        ),
      ],
    );
  }
}
