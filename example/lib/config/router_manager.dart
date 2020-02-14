import 'package:flutter/material.dart';
import 'package:social_foundation_example/pages/account/login_page.dart';
import 'package:social_foundation_example/pages/tab_navigator.dart';

class RouteName {
  static const String Splash = 'splash';
  static const String Tab = '/';
  static const String Login = 'login';
  static const String Register = 'register';
  static const String Message = 'message';
  static const String Settings = 'settings';
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.Login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case RouteName.Tab:
        return MaterialPageRoute(builder: (_) => TabNavigator());
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