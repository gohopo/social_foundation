import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfRollingNumber extends StatelessWidget{
  SfRollingNumber({
    Key? key,
    required this.number,
    required this.style,
    this.duration = const Duration(milliseconds:400)
  }) : super(key:key);
  final String? number;
  final TextStyle style;
  final Duration duration;

  Widget build(_) => SfProvider<SfRollingNumberVM>(
    model: SfRollingNumberVM(this),
    builder: (_,model,__) => AnimatedBuilder(
      animation: model.controller,
      builder: (_,__) => Row(
        mainAxisSize: MainAxisSize.min,
        children: model.numbers!.asMap().keys.map((index) => buildNumber(model,index)).toList(),
      ),
    )
  );
  Widget buildNumber(SfRollingNumberVM model,int index){
    var number = int.tryParse(model.numbers![index]);
    if(number == null) return Text(model.numbers![index],style:style);
    var animation = Tween<double>(
      begin: (int.tryParse(model.oldNumbers[index]) ?? 0) * 0.4,
      end: number * 0.4
    ).animate(model.controller);
    return Stack(
      children: <Widget>[
        Text('7',style:style.copyWith(color:Colors.transparent,shadows:[])),
        Positioned(
          top: 0,
          child: Align(
            alignment: Alignment(0,-1 + animation.value),
            heightFactor: 0.5,
            child: Column(
              children: ['0','1','2','3','4','5','6','7','8','9'].map((num) => Text(num,style:style)).toList(),
            )
          )
        )
      ],
    );
  }
}
class SfRollingNumberVM extends SfViewState{
  SfRollingNumberVM(this.widget):numbers=widget.number?.split('');
  SfRollingNumber widget;
  late AnimationController controller;
  late List<String> oldNumbers;
  List<String>? numbers;

  Future initDataVsync(vsync){
    controller = AnimationController(duration:widget.duration,vsync:vsync);
    rolling();
    return super.initDataVsync(vsync);
  }
  void onRefactor(covariant SfRollingNumberVM model){
    if(model.widget.number!=widget.number){
      widget = model.widget;
      rolling();
    }
  }
  void rolling() async {
    oldNumbers = numbers ?? [];
    numbers = widget.number?.split('') ?? [];
    if(oldNumbers.length < numbers!.length){
      oldNumbers.insertAll(0, List.filled(numbers!.length-oldNumbers.length, '0'));
    }
    else if(oldNumbers.length > numbers!.length){
      numbers?.insertAll(0, List.filled(oldNumbers.length-numbers!.length, '0'));
    }
    notifyListeners();
    controller.reset();
    await controller.forward();
    numbers = widget.number?.split('') ?? [];
    notifyListeners();
  }
}

class SfRollingNumberEnhanced extends StatelessWidget{
  SfRollingNumberEnhanced({
    Key? key,
    this.number,
    this.duration = const Duration(milliseconds:400),
    required this.height,
    required this.path,
    this.slotImage = '8'
  }) : super(key:key);
  final String? number;
  final Duration duration;
  final double height;
  final String path;
  final String slotImage;

  Widget buildNumberColumn(BuildContext context,SfRollingNumberEnhancedModel model,int index){
    var number = model.getNumber(index);
    if(number == null) return buildNumber(context,model.numbers![index]);
    return Stack(
      children: [
        buildNumberSlot(context),
        buildNumberAnimation(context,model,number,model.getOldNumber(index))
      ],
    );
  }
  Widget buildNumber(BuildContext context,String ch){
    return Image.asset('$path/$ch.png',height:height);
  }
  Widget buildNumberSlot(BuildContext context) => Opacity(
    opacity: 0,
    child: buildNumber(context,slotImage),
  );
  Widget buildNumberAnimation(BuildContext context,SfRollingNumberEnhancedModel model,int number,oldNumber){
    return Positioned(
      top: Tween<double>(
        begin: -oldNumber*height,
        end: -number*height,
      ).animate(model.controller).value,
      child: Column(
        children: ['0','1','2','3','4','5','6','7','8','9'].map<Widget>((ch) => buildNumber(context, ch)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SfProvider<SfRollingNumberEnhancedModel>(
      model: SfRollingNumberEnhancedModel(this),
      builder: (context,model,child) => AnimatedBuilder(
        animation: model.controller,
        builder: (context, child) => Row(
          mainAxisSize: MainAxisSize.min,
          children: model.numbers!.asMap().keys.map((index)=>buildNumberColumn(context, model, index)).toList(),
        ),
      ),
    );
  }
}
class SfRollingNumberEnhancedModel extends SfViewState{
  SfRollingNumberEnhancedModel(this.widget);
  SfRollingNumberEnhanced widget;
  late AnimationController controller;
  late List<String> oldNumbers;
  List<String>? numbers;

  Future initDataVsync(vsync) async {
    controller = AnimationController(duration:widget.duration,vsync:vsync);
    rolling();
  }
  void dispose(){
    controller.dispose();
    super.dispose();
  }
  void onRefactor(SfViewState newState){
    var state = newState as SfRollingNumberEnhancedModel;
    if(state.widget.number!=widget.number){
      widget = state.widget;
      rolling();
    }
  }
  int? getNumber(int index) => int.tryParse(numbers![index]);
  int getOldNumber(int index) => int.tryParse(oldNumbers[index])??0;
  void rolling() async {
    oldNumbers = numbers ?? [];
    numbers = widget.number?.split('') ?? [];
    if(oldNumbers.length < numbers!.length){
      oldNumbers.insertAll(0, List.filled(numbers!.length-oldNumbers.length, '0'));
    }
    else if(oldNumbers.length > numbers!.length){
      numbers?.insertAll(0, List.filled(oldNumbers.length-numbers!.length, '0'));
    }
    notifyListeners();
    controller.reset();
    await controller.forward();
    numbers = widget.number?.split('') ?? [];
    notifyListeners();
  }
}

class SfAnimatedNumber extends StatelessWidget{
  SfAnimatedNumber({
    this.number,
    this.style,
    this.duration = const Duration(milliseconds:400),
    this.framesPerSecond = 100,
    this.numberBuilder
  });
  final double? number;
  final TextStyle? style;
  final Duration duration;
  final int framesPerSecond;
  final String Function(double number)? numberBuilder;

  @override
  Widget build(BuildContext context){
    return SfProvider<SfAnimatedNumberModel>(
      model: SfAnimatedNumberModel(this),
      builder: (context,model,child) => Text(numberBuilder?.call(model.number!)??model.number.toString(),style:style),
    );
  }
}
class SfAnimatedNumberModel extends SfViewState{
  SfAnimatedNumberModel(this.widget):number=widget.number;
  SfAnimatedNumber widget;
  double? number;
  Timer? _timer;
  List<double> _frameList = [];

  Future initData() async => animate();
  void dispose(){
    stop();
    super.dispose();
  }
  void onRefactor(SfViewState newState){
    var state = newState as SfAnimatedNumberModel;
    if(state.widget.number!=widget.number){
      widget = state.widget;
      animate();
    }
  }
  void animate() async {
    stop();
    if(widget.number==null || widget.number==number) return;
    if(number==null) number = widget.number;
    _frameList = [];
    var random = Random();
    int count = widget.duration.inMilliseconds*widget.framesPerSecond~/1000;
    double num = number!;
    do{
      double step = random.nextDouble()*(widget.number!-number!)*2/count;
      num += step;
      if(step>0&&num>widget.number! || step<0&&num<widget.number!){
        num = widget.number!;
      }
      _frameList.add(num);
    }
    while(num!=widget.number);
    _timer = Timer.periodic(Duration(milliseconds:widget.duration.inMilliseconds~/count),onUpdate);
  }
  void stop(){
    _timer?.cancel();
    _timer = null;
  }
  void onUpdate(timer){
    number = _frameList.removeAt(0);
    notifyListeners();
    if(_frameList.length==0) stop();
  }
}

class SfFlipNumberEnhanced extends StatelessWidget{
  SfFlipNumberEnhanced({
    Key? key,
    this.number,
    this.duration = const Duration(milliseconds:400),
    this.path,
    this.height,
    this.style = const TextStyle(fontSize:32,color:Colors.white,fontWeight:FontWeight.bold),
    this.stringStyle,
    this.dividerHeight = 2,
    this.numberContainerBuilder,
    this.numberContainerSize = const Size(33,46),
    this.numberContainerMargin = const EdgeInsets.symmetric(horizontal:1.5),
    this.numberContainerDecoration = numberContainerDefaultDecoration
  }) : super(key:key);
  final String? number;
  final Duration duration;
  final String? path;
  final double? height;
  final TextStyle style;
  final TextStyle? stringStyle;
  final double dividerHeight;
  final Widget Function(Widget child)? numberContainerBuilder;
  final Size numberContainerSize;
  final EdgeInsetsGeometry numberContainerMargin;
  final BoxDecoration numberContainerDecoration;
  static const BoxDecoration numberContainerDefaultDecoration = BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.all(Radius.circular(4))
  );
  Widget buildNumberColumn(SfFlipNumberEnhancedVM model,int index){
    var number = model.getNumber(index);
    if(number == null) return buildNumber(model.numbers![index],stringStyle??style.copyWith(color:numberContainerDecoration.color));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildNumberAnimation(model,number.toString(),model.getOldNumber(index).toString(),true),
        SizedBox(height:dividerHeight),
        buildNumberAnimation(model,number.toString(),model.getOldNumber(index).toString(),false),
      ],
    );
  }
  Widget buildNumber(String ch,TextStyle style){
    if(path==null) return buildNumberText(ch,style);
    return buildNumberImage(ch);
  }
  Widget buildNumberText(String ch,TextStyle style) => Text(ch,style:style);
  Widget buildNumberImage(String ch) => Image.asset('$path/$ch.png',height:height);
  Widget buildNumberContainer(Widget child) => Container(
    width:numberContainerSize.width,height:numberContainerSize.height,
    margin: numberContainerMargin,
    alignment: Alignment.center,
    decoration: numberContainerDecoration,
    child: child
  );
  Widget buildNumberClip(String ch,Alignment alignment) => ClipRect(
    child: Align(
      alignment: alignment,
      heightFactor: 0.5,
      child: (numberContainerBuilder??buildNumberContainer).call(buildNumber(ch,style)),
    ),
  );
  Widget buildNumberAnimation(SfFlipNumberEnhancedVM model,String number,String oldNumber,bool top) => Stack(
    children: [
      buildNumberClip(top?number:oldNumber,top?Alignment.topCenter:Alignment.bottomCenter),
      if(number!=oldNumber) Transform(
        transform: Matrix4.identity()
          ..setEntry(3,2,0.006)
          ..rotateX(top ? (model.isReversePhase?pi/2:model.rotateX.value) : (model.isReversePhase?-model.rotateX.value:pi/2)),
        alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
        child: buildNumberClip(!top?number:oldNumber,!top?Alignment.bottomCenter:Alignment.topCenter),
      )
    ],
  );

  Widget build(BuildContext context) => SfProvider<SfFlipNumberEnhancedVM>(
    model: SfFlipNumberEnhancedVM(this),
    builder: (_,model,__) => AnimatedBuilder(
      animation: model.controller,
      builder: (_,__) => Row(
        mainAxisSize: MainAxisSize.min,
        children: model.numbers!.asMap().keys.map((index)=>buildNumberColumn(model,index)).toList(),
      )
    )
  );
}
class SfFlipNumberEnhancedVM extends SfViewState{
  SfFlipNumberEnhancedVM(this.widget);
  SfFlipNumberEnhanced widget;
  late AnimationController controller;
  late List<String> oldNumbers;
  List<String>? numbers;
  late Animation<double> rotateX;
  bool isReversePhase = false;
  Future initDataVsync(vsync) async {
    controller = AnimationController(duration:widget.duration,vsync:vsync);
    controller.addStatusListener((status){
      if(status == AnimationStatus.completed) {
        controller.reverse();
        isReversePhase = true;
        notifyListeners();
      }
    });
    rotateX = Tween(begin:0.0001,end:pi/2).animate(controller);
    flip();
  }
  void dispose(){
    controller.dispose();
    super.dispose();
  }
  void onRefactor(SfViewState newState){
    var state = newState as SfFlipNumberEnhancedVM;
    if(state.widget.number!=widget.number){
      widget = state.widget;
      flip();
    }
  }
  int? getNumber(int index) => int.tryParse(numbers![index]);
  int getOldNumber(int index) => int.tryParse(oldNumbers[index])??0;
  void flip() async {
    isReversePhase = false;
    oldNumbers = numbers ?? [];
    numbers = widget.number?.split('') ?? [];
    if(oldNumbers.length < numbers!.length){
      oldNumbers.insertAll(0, List.filled(numbers!.length-oldNumbers.length, '0'));
    }
    else if(oldNumbers.length > numbers!.length){
      numbers?.insertAll(0, List.filled(oldNumbers.length-numbers!.length, '0'));
    }
    notifyListeners();
    controller.reset();
    await controller.forward();
    numbers = widget.number?.split('') ?? [];
    notifyListeners();
  }
}
