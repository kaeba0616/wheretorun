import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretorun/constants/gaps.dart';
import 'package:wheretorun/constants/sizes.dart';
import 'package:wheretorun/features/authentication/views/widgets/start_button_container.dart';

class RealHomeScreen extends StatefulWidget {
  static const String routeName = 'realHome';
  static const String routeUrl = '/realHome';

  const RealHomeScreen({super.key});

  @override
  State<RealHomeScreen> createState() => _RealHomeScreenState();
}

class _RealHomeScreenState extends State<RealHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: Sizes.size80,
              bottom: Sizes.size20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  children: [
                    Center(
                      child: Text(
                        "Where to Run",
                        style: TextStyle(
                          fontSize: Sizes.size44,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text("달리기를 시작하세요!"),
                  ],
                ),
                Column(
                  children: [
                    HomeButtonContainer(
                      onStartTap: () {},
                      onExitTap: () {},
                    ),
                    Gaps.v14,
                  ],
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.3,
              child: SizedBox(
                child: FaIcon(
                  FontAwesomeIcons.personRunning,
                  size: Sizes.size96,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
