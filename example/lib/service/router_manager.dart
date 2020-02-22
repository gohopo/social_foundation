import 'package:flutter/material.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/page/account/login_page.dart';
import 'package:social_foundation_example/page/chat/chat_page.dart';
import 'package:social_foundation_example/page/tab_navigator.dart';

class RouteName {
  static const String Splash = 'splash';
  static const String Tab = '/';
  static const String Login = 'login';
  static const String Register = 'register';
  static const String Message = 'message';
  static const String Chat = 'chat';
  static const String Settings = 'settings';
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.Login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case RouteName.Tab:
        return MaterialPageRoute(builder: (_) => TabNavigator());
      case RouteName.Chat:
        return MaterialPageRoute(builder: (_) => ChatPage(conversation: settings.arguments as Conversation));
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