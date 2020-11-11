import 'package:flutter/material.dart';

class SfUnderlineTabIndicator extends Decoration{
  SfUnderlineTabIndicator({
    this.width,
    this.height,
    this.offsetY = 0,
    this.color = Colors.black,
    this.borderRadius = BorderRadius.zero,
    this.gradient
  });
  final double width;
  final double height;
  final double offsetY;
  final Color color;
  final BorderRadiusGeometry borderRadius;
  final LinearGradient gradient;

  @override
  BoxPainter createBoxPainter([onChanged]) => RoundPainter(width:width,height:height,offsetY:offsetY,color:color,borderRadius:borderRadius,gradient:gradient,onChanged:onChanged);
}

class RoundPainter extends BoxPainter{
  RoundPainter({
    this.width,
    this.height,
    this.offsetY = 0,
    this.color = Colors.black,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    this.gradient,
    void Function() onChanged
  }):borderRadius=borderRadius.resolve(TextDirection.ltr),super(onChanged);
  double width;
  double height;
  double offsetY;
  Color color;
  BorderRadius borderRadius;
  LinearGradient gradient;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    var rect = Rect.fromLTWH(offset.dx,offset.dy,width??configuration.size.width,height??configuration.size.height);
    rect = rect.translate((configuration.size.width-rect.width)/2,offsetY+configuration.size.height-rect.height);
    final paint = Paint();
    paint.isAntiAlias=true;
    if(gradient!=null) paint.shader = gradient.createShader(rect);
    else if(color!=null) paint.color = color;
    canvas.drawRRect(RRect.fromRectAndCorners(rect,topLeft:borderRadius.topLeft,topRight:borderRadius.topRight,bottomLeft:borderRadius.bottomLeft,bottomRight:borderRadius.bottomRight),paint);
  }
}