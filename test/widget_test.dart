import 'package:flutter_test/flutter_test.dart';

import 'package:pigeon_planet/core/di/injection.dart';
import 'package:pigeon_planet/core/network/dio_client.dart';
import 'package:pigeon_planet/main.dart';

void main() {
  setUpAll(() {
    if (!sl.isRegistered<DioClient>()) {
      setupDependencies();
    }
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PigeonPlanetApp());
  });
}
