import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/pages/account/login_page.dart';
import 'package:social_foundation_example/pages/chat/chat_page.dart';
import 'package:social_foundation_example/pages/tab_navigator.dart';

class RouteName {
  static const String Splash = 'splash';
  static const String Tab = '/';
  static const String Login = 'login';
  static const String Register = 'register';
  static const String Message = 'message';
  static const String Chat = 'chat';
  static const String Settings = 'settings';
  static const String PhotoViewer = 'photo_viewer';
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
      case RouteName.PhotoViewer:
        var map = settings.arguments as Map;
        return SfFadeRoute(page: SfPhotoGalleryViewer(images:map['images'],index:map['index'],heroTag: map['heroTag']));
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