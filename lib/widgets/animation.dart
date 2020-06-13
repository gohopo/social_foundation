import 'package:flutter/material.dart';

class SfTranslateAnimation extends StatelessWidget{
  SfTranslateAnimation({
    this.controller,
    @required this.child,
    Animation<double> animation,
    this.offsetX = 0,
    this.offsetY = 70,
  }) : animation=animation??CurvedAnimation(parent:controller, curve: Curves.decelerate);
  final AnimationController controller;
  final Widget child;
  final Animation<double> animation;
  final double offsetX;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child)  => Transform.translate(
        offset: Tween<Offset>(
          begin: Offset(offsetX, offsetY),
          end: Offset(0, 0),
        ).animate(animation).value,
        child: Opacity(
          opacity: Tween<double>(
            begin: 0, end: 1
          ).animate(animation).value,
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class SfFadeAnimation extends StatelessWidget{
  SfFadeAnimation({
    AnimationController controller,
    @required this.child,
    Animation<double> animation,
  }) : animation=animation??CurvedAnimation(parent:controller, curve: Curves.decelerate);
  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0, end: 1
      ).animate(animation),
      child: child,
    );
  }
}