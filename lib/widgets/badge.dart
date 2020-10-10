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
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal:3.5,vertical:2),
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
      width: width,
      height: height,
      child: Container(
        padding: padding,
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
      clipBehavior: Clip.none,
      children: <Widget>[
        buildChild(),
        if(visible) buildBadge()
      ],
    );
  }
}