import 'package:flutter/material.dart';

class SfMaterialRoute<T> extends MaterialPageRoute<T>{
  SfMaterialRoute(Widget page) : super(
    builder: (context) => page
  );
}

class SfDirectRoute<T> extends PageRouteBuilder<T>{
  SfDirectRoute(Widget page) : super(
    opaque: false,
    transitionDuration: Duration(milliseconds: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (context, animation, secondaryAnimation) => page
  );
}

class SfFadeRoute<T> extends PageRouteBuilder<T>{
  SfFadeRoute(Widget page): super(
    transitionsBuilder: (context,animation,secondaryAnimation,child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
    pageBuilder: (context,animation,secondaryAnimation) => page
  );
}

class SfScaleRoute<T> extends PageRouteBuilder<T>{
  SfScaleRoute(Widget page) : super(
    transitionDuration: Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
      scale: Tween(
        begin: 0.0,
        end: 1.0
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn
        )
      ),
      child: child,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );
}

class SfSlideRoute<T> extends PageRouteBuilder<T>{
  SfSlideRoute(Widget page,{
    Offset begin = const Offset(0.0, 1.0)
  }) : super(
    transitionDuration: Duration(milliseconds: 800),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset(0.0, 0.0)
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn
        )
      ),
      child: child,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => page
  );
}