import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_foundation/utils/utils.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfTranslateAnimation extends StatelessWidget{
  SfTranslateAnimation({
    required this.controller,
    required this.child,
    Animation<double>? animation,
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
      builder: (context, child) => Transform.translate(
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
    required AnimationController controller,
    required this.child,
    Animation<double>? animation,
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

class SfShakeAnimation extends StatelessWidget{
  SfShakeAnimation({
    required this.child,
    this.repeat = 3,
    this.duration = const Duration(milliseconds:200),
    this.delay = const Duration(seconds:1),
    this.angle = 0.01,
  });
  final Widget child;
  final int repeat;
  final Duration duration;
  final Duration delay;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return SfProviderEnhanced<_SfShakeAnimationModel>(
      model: _SfShakeAnimationModel(this),
      onModelReady: (vsync, model){
        model.controller = AnimationController(duration:duration,vsync:vsync);
        model.initData();
      },
      builder: (context,model,_) => RotationTransition(
        turns: model.turns,
        alignment: Alignment.center,
        child: child
      )
    );
  }
}
class _SfShakeAnimationModel extends SfViewState{
  _SfShakeAnimationModel(this.animation);
  SfShakeAnimation animation;
  late AnimationController controller;
  late Animation<double> turns;
  Timer? _timer;

  void startTimer(){
    closeTimer();
    _timer = Timer.periodic(animation.duration*(1+animation.repeat)*2+animation.delay, (_) => start());
  }
  void closeTimer(){
    _timer?.cancel();
    _timer = null;
  }
  void start() async {
    turns = Tween<double>(
      begin: 0,
      end: animation.angle
    ).animate(controller);
    await controller.forward();
    
    turns = Tween<double>(
      begin: animation.angle,
      end: -animation.angle
    ).animate(controller);
    notifyListeners();
    for(int i=0;i<animation.repeat;++i){
      await controller.forward();
      await controller.reverse();
    }
    turns = Tween<double>(
      begin: animation.angle,
      end: 0
    ).animate(controller);
    notifyListeners();
    await controller.forward();
  }

  @override
  Future initData() async {
    start();
    startTimer();
  }
  @override
  void dispose(){
    closeTimer();
    controller.dispose();
    super.dispose();
  }
}

class SfRotationAnimation extends StatelessWidget{
  SfRotationAnimation({
    required this.child,
    this.duration = const Duration(seconds:30),
    this.alignment = Alignment.center
  });
  final Widget child;
  final Duration duration;
  final Alignment alignment;

  Widget build(_) => SfProvider<_SfRotationAnimationModel>(
    model: _SfRotationAnimationModel(this),
    builder: (_,model,__) => AnimatedBuilder(
      animation: model.controller,
      builder: (_,child) => RotationTransition(
        turns: model.controller,
        alignment: alignment,
        child: child
      ),
      child: child,
    )
  );
}
class _SfRotationAnimationModel extends SfViewState{
  _SfRotationAnimationModel(this.widget);
  SfRotationAnimation widget;
  late AnimationController controller;

  Future initDataVsync(vsync) async {
    controller = AnimationController(duration:widget.duration,vsync:vsync);
    controller.addStatusListener((status){
      if(status == AnimationStatus.completed){
        controller.reset();
        controller.forward();
      }
    });
    controller.forward();
    return super.initDataVsync(vsync);
  }
  void dispose(){
    controller.dispose();
    super.dispose();
  }
}

class SfAnimatedDouble extends ImplicitlyAnimatedWidget{
  SfAnimatedDouble({
    Key? key,
    required this.builder,
    required this.value,
    this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd
  }) : super(key:key,curve:curve,duration:duration,onEnd:onEnd);
  final ValueWidgetBuilder<double> builder;
  final double value;
  final Widget? child;

  @override
  AnimatedWidgetBaseState<SfAnimatedDouble> createState() => _SfAnimatedDoubleState();
}
class _SfAnimatedDoubleState extends AnimatedWidgetBaseState<SfAnimatedDouble>{
  Tween<double>? _value;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _value = visitor(_value, widget.value, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
  }
  @override
  Widget build(BuildContext context) {
    return widget.builder(context,_value!.evaluate(animation),widget.child);
  }
}

class SfHeartFadeAnimation extends StatelessWidget{
  SfHeartFadeAnimation({required Widget heart,required this.position,required this.translateY,this.onCompleted})
  :heart=Transform.rotate(angle:SfUtils.randRangeDouble(-0.5,0.5),child:heart);
  final Widget heart;
  final Offset position;
  final double translateY;
  final Function? onCompleted;
  @override
  Widget build(context) => SfProvider<SfHeartFadeAnimationVM>(
    model: SfHeartFadeAnimationVM(this),
    builder: (_,model,__)=>buildWidget(model)
  );
  Widget buildWidget(SfHeartFadeAnimationVM model) => AnimatedBuilder(
    animation: model.controller,
    builder: (_,child) => Stack(
      children: [
        buildHeart(model,child!),
      ],
    ),
    child: heart,
  );
  Widget buildHeart(SfHeartFadeAnimationVM model,Widget heart) => Positioned(
    left:position.dx,top:model.top,
    child: Transform.scale(
      scale: model.scale,
      child: Opacity(
        opacity: model.opacity,
        child: heart
      )
    )
  );
}
class SfHeartFadeAnimationVM extends SfViewState{
  SfHeartFadeAnimationVM(this.widget);
  SfHeartFadeAnimation widget;
  late AnimationController controller;
  double get step1 => 1.5;
  double get step2 => 0.5;
  double get step3 => 4;
  double get step4 => 6;
  double get top => TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween<double>(widget.position.dy),
      weight: step1+step2+step3
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin:widget.position.dy,end:widget.position.dy+widget.translateY,
      ),
      weight: step4
    ),
  ]).animate(CurvedAnimation(
    parent:controller,curve:Curves.linear
  )).value;
  double get scale => TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin:1.2,end:0.9,
      ),
      weight: step1
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin:0.9,end:1,
      ),
      weight: step2
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1),
      weight: step3
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin:1,end:1.5,
      ),
      weight: step4
    ),
  ]).animate(CurvedAnimation(
    parent:controller,curve:Curves.linear
  )).value;
  double get opacity => TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween<double>(1),
      weight: step1+step2+step3
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin:1,end:0.1,
      ),
      weight: step4
    ),
  ]).animate(CurvedAnimation(
    parent:controller,curve:Curves.linear
  )).value;
  @override
  Future initDataVsync(vsync) async {
    controller = AnimationController(duration:const Duration(milliseconds:900),vsync:vsync);
    startAnimation();
  }
  void startAnimation() async {
    await controller.forward();
    widget.onCompleted?.call();
  }
}
