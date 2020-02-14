import 'package:flutter/material.dart';

import 'config/router_manager.dart';

void main() async {
  runApp(App());
}

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