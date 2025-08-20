import 'package:flutter/material.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/widgets/page_route.dart';

class SfRouterManager extends NavigatorObserver{
  static NavigatorState getNavigator({NavigatorState? navigator,BuildContext? context}) => (navigator ?? (context!=null ? Navigator.of(context) : SfLocatorManager.routerManager.navigator))!;
  static Future<T?> go<T extends Object?>(Widget page,{NavigatorState? navigator,BuildContext? context}) => route(SfMaterialRoute(page),navigator:navigator,context:context);
  static Future<T?> goEmpty<T extends Object?>(Widget page,{NavigatorState? navigator,BuildContext? context}) => routeEmpty(SfMaterialRoute(page),navigator:navigator,context:context);
  static Future<T?> goReplacement<T extends Object?>(Widget page,{NavigatorState? navigator,BuildContext? context}) => routeReplacement(SfMaterialRoute(page),navigator:navigator,context:context);
  static Future<T?> route<T extends Object?>(Route<T> route,{NavigatorState? navigator,BuildContext? context}) => getNavigator(navigator:navigator,context:context).push(route);
  static Future<T?> routeEmpty<T extends Object?>(Route<T> route,{NavigatorState? navigator,BuildContext? context}) => getNavigator(navigator:navigator,context:context).pushAndRemoveUntil(route,(_)=>false);
  static Future<T?> routeReplacement<T extends Object?>(Route<T> route,{NavigatorState? navigator,BuildContext? context}) => getNavigator(navigator:navigator,context:context).pushReplacement(route);
  static void pop<T extends Object?>({T? result,NavigatorState? navigator,BuildContext? context}) => getNavigator(navigator:navigator,context:context).pop(result);

  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
  Route<dynamic> generateRoute(RouteSettings settings) => MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(
        child: Text('No route defined for ${settings.name}')
      )
    )
  );
}