# WhereToRun - 실시간 음성 안내 기반 보행자 경로 앱

1. 앱 개요

WhereToRun: 실시간 위치 기반 보행자 경로 앱

2. 기능

- 네이버 지도 API를 활용하여 사용자의 현재 위치를 기반으로 경로를 탐색하고 음성 안내를 제공하는 앱
- 사용자가 설정한 목적지까지 경유지를 포함한 최적의 경로를 제공
- 방향성에 따른 좌/우 비프음으로 음성 안내를 제공 (각도에 따른 알림음 조절)
- 실시간으로 위치를 추적하여 다양한 이벤트시 알림을 제공

1. 사용 기술 스택

   • Flutter와 Dart를 사용하여 앱 개발. (크로스 플랫폼은 추후에 가능)
   • NaverMap API를 통해 실시간 위치 및 지도 기능 제공.
   • TMap API를 통해 경로 탐색 및 안내 기능 제공.
   • Geolocator로 위치 추적 및 실시간 위치 업데이트를 효율적으로 수행.
   • AudioPlayers 패키지를 통해 좌/우 비프음을 조정해 이어폰 착용 시 방향성을 안내.
   • Riverpod을 사용하여 효율적이고 모듈화된 상태 관리를 구현.

2. UI 구성

   1. 지도 화면
      • 앱 시작 시 현재 위치 기반의 지도를 로딩하며, 시작점과 목적지 설정 후 경로를 표시.
      • 경로 생성 및 달리기 시작 버튼 제공.
   2. 경로 생성 및 안내
      • 경유지와 목적지에 도달 시 경고 음성 안내 및 텍스트로 상태 표시.
   3. 위치 컨트롤 패널 (테스트용)
      • 화면 상단에 위치한 패널을 통해 상/하/좌/우 방향으로 위치 이동 테스트 가능
   4. 시작 및 비프음 조절 버튼
      • 경로 안내 시작 및 테스트용 비프음
