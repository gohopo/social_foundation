import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SfRouterManager extends NavigatorObserver{
  Route<dynamic> generateRoute(RouteSettings settings){
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}')
        )
      )
    );
  }
}