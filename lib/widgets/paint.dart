import 'package:flutter/material.dart';
import 'package:social_foundation/widgets/path.dart';

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

class GradientRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  GradientRectSliderTrackShape({this.gradient=const LinearGradient(colors:[Colors.lightBlue,Colors.blue]),this.darkenInactive=true});
  final LinearGradient gradient;
  final bool darkenInactive;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = darkenInactive
      ? ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor) 
      : activeTrackColorTween;
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2): trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr) ? activeTrackRadius : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr) ? activeTrackRadius: trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}

class SfCubicPathPainter extends CustomPainter{
  SfCubicPathPainter({
    this.heightWeights,this.heightWeightFn,this.currentDot,
    this.lineColor=const Color.fromRGBO(120,152,188,0.3),this.dotColor=const Color.fromRGBO(120,152,188,0.5)
  }){
    heightWeightFn ??= (index,heightWeight) => heightWeight;
  }
  List<double> heightWeights;
  double Function(int index,double heightWeight) heightWeightFn;
  int currentDot;
  Color lineColor;
  Color dotColor;
  void paintLine(List<Offset> dots,{Canvas canvas,Size size,Color color}){
    var path = SfPath.getCubicPath(dots:dots);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }
  void paintDots(List<Offset> dots,{Canvas canvas,Color color}){
    for(var i=0;i<dots.length;++i){
      if(currentDot==null || currentDot==i) paintDot(
        canvas:canvas,offset:dots[i],color:color
      );
    }
  }
  void paintDot({Canvas canvas,Offset offset,Color color,double radius=4}){
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawCircle(offset, radius, paint);
  }

  void paint(Canvas canvas,Size size){
    var dots = SfCubicPathClipper.getDots(size:size,heightWeights:heightWeights,heightWeightFn:heightWeightFn);
    paintLine(dots,canvas:canvas,size:size,color:lineColor);
    paintDots(dots,canvas:canvas,color:dotColor);
  }
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SfCustomPainter extends CustomPainter{
  SfCustomPainter({this.onPaint,this.onShouldRepaint});
  void Function(Canvas canvas, Size size) onPaint;
  bool Function() onShouldRepaint;
  void paint(Canvas canvas, Size size) => onPaint?.call(canvas,size);
  bool shouldRepaint(_) => onShouldRepaint?.call() ?? true;
}
