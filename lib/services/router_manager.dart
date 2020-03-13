import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_foundation/pages/photo_viewer.dart';
import 'package:social_foundation/widgets/page_route.dart';

class SfRouteName {
  static const String Splash = 'splash';
  static const String Tab = '/';
  static const String Signin = 'signin';
  static const String Signup = 'signup';
  static const String Message = 'message';
  static const String Chat = 'chat';
  static const String Settings = 'settings';
  static const String PhotoViewer = 'photo_viewer';
}

class SfRouterManager extends NavigatorObserver{
  Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case SfRouteName.PhotoViewer:
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