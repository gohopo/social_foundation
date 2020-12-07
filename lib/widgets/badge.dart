import 'package:flutter/material.dart';

class SfBadge extends StatelessWidget {
  SfBadge({
    Key key,
    this.child,
    this.visible = true,
    this.left,
    this.top = 0,
    this.right = 0,
    this.bottom,
    this.width = 10,
    this.height = 10,
    this.padding = const EdgeInsets.symmetric(horizontal:2,vertical:1),
    this.color = Colors.red,
    this.borderRadius = const BorderRadius.all(Radius.circular(9)),
    this.text,
    this.textStyle = const TextStyle(fontSize: 8,color: Colors.white)
  }) : super(key:key);

  final Widget child;
  final bool visible;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius borderRadius;
  final String text;
  final TextStyle textStyle;

  Widget buildChild(){
    return child ?? Container();
  }
  Widget buildBadge(){
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        padding: padding,
        constraints: BoxConstraints(
          minWidth: width??0,
          minHeight: height??0
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius
        ),
        alignment: Alignment.center,
        child: text!=null ? Text(text,style:textStyle) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: <Widget>[
        buildChild(),
        if(visible) buildBadge()
      ],
    );
  }
}