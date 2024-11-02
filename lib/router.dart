import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheretorun/features/authentication/views/real_home_screen.dart';
import 'package:wheretorun/features/naviagtion/views/home_screen.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: RealHomeScreen.routeUrl,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: RealHomeScreen.routeUrl,
          name: RealHomeScreen.routeName,
          builder: (context, state) {
            return const RealHomeScreen();
          },
        ),
        GoRoute(
          path: HomeScreen.routeUrl,
          name: HomeScreen.routeName,
          builder: (context, state) {
            return const HomeScreen();
          },
        ),
      ],
    );
  },
);
