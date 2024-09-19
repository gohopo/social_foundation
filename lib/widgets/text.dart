import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfStrokeText extends StatelessWidget{
  SfStrokeText({
    required this.child,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeWidth = 6.0,
    this.strokeColor = const Color.fromRGBO(53,0,71,1),
  });
  final double strokeWidth;
  final Color strokeColor;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final Text child;

  @override
  Widget build(BuildContext context) {
    TextStyle? style;
    if(child.style != null){
      style = child.style?.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = strokeCap
          ..strokeJoin = strokeJoin
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
        color: null,
      );
    }
    else{
      style = TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = strokeCap
          ..strokeJoin = strokeJoin
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
      );
    }
    return Stack(
      alignment: Alignment.center,
      textDirection: child.textDirection,
      children: [
        Text(
          child.data!,
          style: style,
          maxLines: child.maxLines,
          overflow: child.overflow,
          semanticsLabel: child.semanticsLabel,
          softWrap: child.softWrap,
          strutStyle: child.strutStyle,
          textAlign: child.textAlign,
          textDirection: child.textDirection,
          textScaleFactor: child.textScaleFactor,
        ),
        child,
      ],
    );
  }
}

class SfLoadingText extends StatelessWidget{
  SfLoadingText({this.text,TextStyle? style}):style=TextStyle(fontSize:24.sp,color:const Color.fromRGBO(100,100,100,1)).merge(style);
  final String? text;
  final TextStyle style;
  @override
  Widget build(context) => SfProvider<SfLoadingTextVM>(
    model: SfLoadingTextVM(this),
    builder: (_,model,__)=>buildText(model)
  );
  Widget buildText(SfLoadingTextVM model) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(text??'加载中',style:style),
      ...buildDots(model),
    ]
  );
  List<Widget> buildDots(SfLoadingTextVM model){
    var dots = model._timer!=null ? model._timer!.tick%4 : 0;
    return List.generate(3,(index) => AnimatedOpacity(
      duration: const Duration(milliseconds:300),
      opacity: index<dots ? 1 : 0,
      child: Text('.',style:style)
    ));
  }
}
class SfLoadingTextVM extends SfViewState{
  SfLoadingTextVM(this.widget);
  SfLoadingText widget;
  Timer? _timer;
  @override
  Future initData(){
    startTimer();
    return super.initData();
  }
  @override
  void dispose(){
    cancelTimer();
    super.dispose();
  }
  void startTimer(){
    _timer ??= Timer.periodic(const Duration(seconds:1),(_)=>notifyListeners());
  }
  void cancelTimer(){
    _timer?.cancel();
    _timer = null;
  }
}
