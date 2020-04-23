import 'package:flutter/material.dart';

class SfRollingNumber extends StatefulWidget{
  SfRollingNumber({
    Key key,
    this.number,
    this.style,
    this.duration = const Duration(milliseconds:400)
  }) : super(key:key);
  final String number;
  final TextStyle style;
  final Duration duration;

  @override
  SfRollingNumberState createState() => SfRollingNumberState();
}

class SfRollingNumberState extends State<SfRollingNumber> with SingleTickerProviderStateMixin{
  AnimationController controller;
  List<String> oldNumbers;
  List<String> numbers;

  void rolling() async {
    setState((){
      oldNumbers = numbers ?? [];
      numbers = widget.number?.split('') ?? [];
      if(oldNumbers.length < numbers.length){
        oldNumbers.insertAll(0, List.filled(numbers.length-oldNumbers.length, '0'));
      }
      else if(oldNumbers.length > numbers.length){
        numbers.insertAll(0, List.filled(oldNumbers.length-numbers.length, '0'));
      }
    });
    controller.reset();
    await controller.forward();
    setState((){
      numbers = widget.number?.split('') ?? [];
    });
  }
  Widget buildNumber(int index){
    var number = int.tryParse(numbers[index]);
    if(number == null) return Text(numbers[index],style:widget.style);
    var animation = Tween<double>(
      begin: (int.tryParse(oldNumbers[index]) ?? 0) * 0.4,
      end: number * 0.4
    ).animate(controller);
    return Stack(
      children: <Widget>[
        Text('7',style:widget.style.copyWith(color:Colors.transparent)),
        Positioned(
          top: 0,
          child: Align(
            alignment: Alignment(0,-1 + animation.value),
            heightFactor: 0.5,
            child: Column(
              children: ['0','1','2','3','4','5','6','7','8','9'].map((num) => Text(num,style:widget.style)).toList(),
            )
          )
        )
      ],
    );
  }

  @override
  void initState(){
    controller = AnimationController(duration:widget.duration,vsync:this);
    rolling();
    super.initState();
  }
  @override
  void didUpdateWidget(SfRollingNumber oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.number != oldWidget.number) rolling();
  }
  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(
      animation: controller,
      builder: (context,child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: numbers.asMap().keys.map(buildNumber).toList(),
      ),
    );
  }
}