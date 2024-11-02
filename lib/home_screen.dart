import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:wheretorun/constants/gaps.dart';
import 'package:wheretorun/constants/sizes.dart';
import 'package:wheretorun/features/common/widgets/start_button_container.dart';
import 'package:wheretorun/features/naviagtion/views/running_screen.dart';
import 'package:wheretorun/utils.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';
  static const String routeUrl = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스를 활성화해주세요.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      final requestPermission = await Geolocator.requestPermission();
      if (requestPermission == LocationPermission.denied ||
          requestPermission == LocationPermission.deniedForever) {
        showMessageDialog(
          context,
          '위치 권한이 필요합니다.',
          () => SystemNavigator.pop(),
        );
        // 앱 종료
      }
    }
  }

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
                    Text(
                      "달리기를 시작하세요!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    HomeButtonContainer(
                      onStartTap: () {
                        context.go(
                          RunningScreen.routeUrl,
                        );
                      },
                      onExitTap: () {},
                    ),
                    Gaps.v36,
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
