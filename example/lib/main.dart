import 'package:flutter/material.dart';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/config/secrets.dart';
import 'config/router_manager.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'social foundation',
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouteName.Login,
    );
  }
}

void main() async {
  await initApp();
  runApp(App());
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  ChatService.initialize(LeancloudSecret.appId, LeancloudSecret.appKey, LeancloudSecret.serverURL);
  ChatService.getInstance().handleMessages().listen((data){
    print(data);
  });
}