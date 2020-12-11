import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_foundation/pages/photo_viewer.dart';
import 'package:social_foundation/widgets/page_route.dart';

class SfRouteName {
  static const String photo_viewer = 'photo_viewer';
}

class SfRouterManager extends NavigatorObserver{
  void showPhotoViewer({List<ImageProvider> images,int index,String heroPrefix,PageController controller}) => navigator.pushNamed(SfRouteName.photo_viewer,arguments:{'images':images,'index':index,'heroPrefix':heroPrefix,'controller':controller});
  @override
  void didPop(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
  Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case SfRouteName.photo_viewer:
        return SfFadeRoute(SfPhotoGalleryViewer(settings.arguments));
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