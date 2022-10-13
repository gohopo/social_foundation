import 'package:flutter/material.dart';

class SfRouteName {
}

class SfRouterManager extends NavigatorObserver{
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
  Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}')
            )
          )
        );
    }
  }
}