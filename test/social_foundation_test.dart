import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_foundation/social_foundation.dart';

void main() {
  const MethodChannel channel = MethodChannel('social_foundation');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SocialFoundation.platformVersion, '42');
  });
}
