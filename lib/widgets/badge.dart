import 'package:flutter/material.dart';

class SfBadge extends StatelessWidget {
  SfBadge({
    super.key,
    this.child,
    this.visible = true,
    this.left,
    this.top = 0,
    this.right = 0,
    this.bottom,
    this.width = 10,
    this.height = 10,
    this.padding = const EdgeInsets.symmetric(horizontal:2,vertical:1),
    this.decoration,
    this.foregroundDecoration,
    this.color = Colors.red,
    this.borderRadius = const BorderRadius.all(Radius.circular(9)),
    this.text,
    this.textStyle = const TextStyle(fontSize:8,color:Colors.white)
  });
  final Widget? child;
  final bool visible;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;
  final BoxDecoration? foregroundDecoration;
  final Color color;
  final BorderRadius borderRadius;
  final String? text;
  final TextStyle textStyle;
  @override
  Widget build(context){
    if(!visible) return buildChild();
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        buildChild(),
        buildBadge()
      ],
    );
  }
  Widget buildBadge() => Positioned(
    left:left,top:top,right:right,bottom:bottom,
    child: Container(
      constraints: BoxConstraints(
        minWidth: width??0,
        minHeight: height??0
      ),
      padding: padding,
      alignment: Alignment.center,
      decoration: decoration ?? BoxDecoration(
        color: color,
        borderRadius: borderRadius
      ),
      foregroundDecoration: foregroundDecoration,
      child: text!=null ? Text(text!,style:textStyle) : null,
    ),
  );
  Widget buildChild() => child ?? const SizedBox();
}