import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheretorun/home_screen.dart';
import 'package:wheretorun/features/naviagtion/views/running_screen.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: HomeScreen.routeUrl,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: HomeScreen.routeUrl,
          name: HomeScreen.routeName,
          builder: (context, state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: RunningScreen.routeUrl,
          name: RunningScreen.routeName,
          builder: (context, state) {
            return const RunningScreen();
          },
        ),
      ],
    );
  },
);
