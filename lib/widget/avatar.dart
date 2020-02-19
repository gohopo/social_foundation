import 'dart:math';

import 'package:flutter/material.dart';

class Avatar extends StatelessWidget{
  Avatar({
    Key key,
    this.width,
    this.height,
    this.decoration,
    this.borderRadius,
    this.radius,
    this.image,
    this.child,
    this.onTap,
  }) : super(key: key);

  final double width;
  final double height;
  final Decoration decoration;
  final BorderRadiusGeometry borderRadius;
  final double radius;
  final ImageProvider image;
  final Widget child;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: buildContainer(context),
    );
  }
  @protected
  Widget buildContainer(BuildContext context){
    return Container(
      width: width,
      height: height,
      decoration: buildDecoration(),
      child: child,
    );
  }
  @protected
  Decoration buildDecoration(){
    return decoration ?? BoxDecoration(
      image: buildImage(),
      borderRadius: buildBorderRadius()
    );
  }
  @protected
  DecorationImage buildImage(){
    return image!=null ? DecorationImage(
      image: image,
      fit: BoxFit.cover
    ) : null;
  }
  @protected
  BorderRadiusGeometry buildBorderRadius(){
    if(borderRadius != null) return borderRadius;
    double r = radius ?? (width!=null ? max(width/2,1) : 1);
    return BorderRadius.all(Radius.circular(r));
  }
}