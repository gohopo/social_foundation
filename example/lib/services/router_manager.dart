import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/pages/account/signin_page.dart';
import 'package:social_foundation_example/pages/chat/chat_page.dart';
import 'package:social_foundation_example/pages/tab_navigator.dart';

class RouteName {
  static const String Splash = 'splash';
  static const String Tab = '/';
  static const String Signin = 'signin';
  static const String Signup = 'signup';
  static const String Message = 'message';
  static const String Chat = 'chat';
  static const String Settings = 'settings';
  static const String user_profile = 'user_profile';
  static const String PhotoViewer = 'photo_viewer';
}

class RouterManager extends SfRouterManager{
  static RouterManager get instance => GetIt.instance<SfRouterManager>();

  @override
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.Signin:
        return MaterialPageRoute(builder: (_) => SigninPage());
      case RouteName.Tab:
        return MaterialPageRoute(builder: (_) => TabNavigator());
      case RouteName.Chat:
        return MaterialPageRoute(builder: (_) => ChatPage(settings.arguments));
      default:
        return super.generateRoute(settings);
    }
  }
}