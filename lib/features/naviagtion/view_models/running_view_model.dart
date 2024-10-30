// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wheretorun/features/naviagtion/services/running_service.dart';
// import 'package:wheretorun/features/naviagtion/models/route_data.dart';

// class RunningViewModel extends StateNotifier<int> {
//   final RunningService _runningService;

//   RunningViewModel(this._runningService) : super(0);

//   void initializeService(RouteData routeData) {
//     _runningService.routeData = routeData;
//     state = _runningService.remainDistance; // 초기 remainDistance 설정

//     _runningService.start();
//   }

//   void _updateRemainingDistance() {
//     state = _runningService.updateRemainingDistance();
//   }

//   void move(String direction) {
//     switch (direction) {
//       case 'up':
//         _runningService.moveUp();
//         break;
//       case 'down':
//         _runningService.moveDown();
//         break;
//       case 'left':
//         _runningService.moveLeft();
//         break;
//       case 'right':
//         _runningService.moveRight();
//         break;
//     }
//     _updateRemainingDistance();
//   }

//   void moveUp() => move('up');
//   void moveDown() => move('down');
//   void moveLeft() => move('left');
//   void moveRight() => move('right');
// }

// final runningProvider = StateNotifierProvider<RunningViewModel, int>(
//   (ref) => RunningViewModel(),
// );
