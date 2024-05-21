import 'package:flutter/material.dart';

class SfPath{
  static Path getScaledPath(Path path,double x,double y){
    var matrix4 = Matrix4.identity();
    matrix4.scale(x,y);
    return path.transform(matrix4.storage);
  }
  static Path getHeartPath(){
    return Path()
      ..moveTo(55, 15)
      ..cubicTo(55, 12, 50, 0, 30, 0)
      ..cubicTo(0, 0, 0, 37.5, 0, 37.5)
      ..cubicTo(0, 55, 20, 77, 55, 95)
      ..cubicTo(90, 77, 110, 55, 110, 37.5)
      ..cubicTo(110, 37.5, 110, 0, 80, 0)
      ..cubicTo(65, 0, 55, 12, 55, 15)
      ..close();
  }
  static Path getApplePath(double w, double h){
    return Path()
      ..moveTo(w * .50779, h * .28732)
      ..cubicTo(
          w * .4593, h * .28732, w * .38424, h * .24241, w * .30519, h * .24404)
      ..cubicTo(
          w * .2009, h * .24512, w * .10525, h * .29328, w * .05145, h * .36957)
      ..cubicTo(w * -.05683, h * .5227, w * .02355, h * .74888, w * .12916,
          h * .87333)
      ..cubicTo(w * .18097, h * .93394, w * .24209, h * 1.00211, w * .32313,
          h * .99995)
      ..cubicTo(w * .40084, h * .99724, w * .43007, h * .95883, w * .52439,
          h * .95883)
      ..cubicTo(w * .61805, h * .95883, w * .64462, h * .99995, w * .72699,
          h * .99833)
      ..cubicTo(
          w * .81069, h * .99724, w * .86383, h * .93664, w * .91498, h * .8755)
      ..cubicTo(
          w * .97409, h * .80515, w * .99867, h * .73698, w * 1, h * .73319)
      ..cubicTo(w * .99801, h * .73265, w * .83726, h * .68233, w * .83526,
          h * .53082)
      ..cubicTo(
          w * .83394, h * .4042, w * .96214, h * .3436, w * .96812, h * .34089)
      ..cubicTo(
          w * .89505, h * .25378, w * .78279, h * .24404, w * .7436, h * .24187)
      ..cubicTo(
          w * .6413, h * .23538, w * .55561, h * .28732, w * .50779, h * .28732)
      ..close()
      ..moveTo(w * .68049, h * .15962)
      ..cubicTo(w * .72367, h * .11742, w * .75223, h * .05844, w * .74426, 0)
      ..cubicTo(w * .68249, h * .00216, w * .60809, h * .03355, w * .56359,
          h * .07575)
      ..cubicTo(w * .52373, h * .11309, w * .48919, h * .17315, w * .49849,
          h * .23051)
      ..cubicTo(w * .56691, h * .23484, w * .63732, h * .20183, w * .68049,
          h * .15962)
      ..close();
  }
  static Path getCubicPath({required List<Offset> dots,double smoothness=0.35,bool preventCurveOverShooting=true,double preventCurveOvershootingThreshold=10.0}){
    var path = Path();
    path.moveTo(dots.first.dx, dots.first.dy);
    
    var temp = Offset.zero;
    for(var i=1;i<dots.length;++i){
      final current=dots[i],previous=dots[i-1],next=dots[i+1<dots.length ? i+1 : i];
      final controlPoint1 = previous + temp;
      temp = ((next - previous) / 2) * smoothness;
      if(preventCurveOverShooting){
        if((next - current).dy <= preventCurveOvershootingThreshold ||
            (current - previous).dy <= preventCurveOvershootingThreshold){
          temp = Offset(temp.dx, 0);
        }
        if((next - current).dx <= preventCurveOvershootingThreshold ||
            (current - previous).dx <= preventCurveOvershootingThreshold){
          temp = Offset(0, temp.dy);
        }
      }
      final controlPoint2 = current - temp;
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }
    return path;
  }
}

class SfPathClipper extends CustomClipper<Path>{
  SfPathClipper({required this.pathBuilder,this.whenReclip});
  final Path Function(Size size) pathBuilder;
  final bool Function(SfPathClipper clipper)? whenReclip;
  @override
  Path getClip(Size size) => pathBuilder.call(size);
  @override
  bool shouldReclip(covariant SfPathClipper clipper) => whenReclip?.call(clipper)??false;
}

class SfTrapezoidClipper extends CustomClipper<Path>{
  SfTrapezoidClipper(this.cutLength, this.edge);
  final double cutLength;
  final AxisDirection edge;

  Path _getLeftPath(Size size) {
    var path = Path();
    path.moveTo(0.0, cutLength);
    path.lineTo(0.0, size.height - cutLength);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }
  Path _getUpPath(Size size) {
    var path = Path();
    path.moveTo(cutLength, 0.0);
    path.lineTo(size.width - cutLength, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }
  Path _getRightPath(Size size) {
    var path = Path();
    path.lineTo(size.width, cutLength);
    path.lineTo(size.width, size.height - cutLength);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }
  Path _getDownPath(Size size) {
    var path = Path();
    path.lineTo(cutLength, size.height);
    path.lineTo(size.width - cutLength, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    switch (edge) {
      case AxisDirection.left:
        return _getLeftPath(size);
      case AxisDirection.up:
        return _getUpPath(size);
      case AxisDirection.right:
        return _getRightPath(size);
      default:
        return _getDownPath(size);
    }
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    SfTrapezoidClipper oldie = oldClipper as SfTrapezoidClipper;
    return cutLength != oldie.cutLength || edge != oldie.edge;
  }
}


class SfCubicPath{
  static CatmullRomSpline getCatmullRomSpline(List<Offset> controlPoints) => CatmullRomSpline(
    controlPoints,
    startHandle: Offset(0.099, 0.102),
    endHandle: Offset(0.91, 0.66),
    tension: 0.0,
  );
  static List<Offset> getDots(CatmullRomSpline catmullRomSpline,Size size,{double start=0,double end=1}){
    var samples = catmullRomSpline.generateSamples(start:start,end:end);
    return samples.map<Offset>((x) => getDot(x.value,size)).toList();
  }
  static Offset getDot(Offset controlPoint,Size size) => Offset(size.width*controlPoint.dx,size.height*controlPoint.dy);
  static Path getPath(List<Offset> dots){
    var path = Path();
    path.moveTo(dots.first.dx, dots.first.dy);
    dots.forEach((x) => path.lineTo(x.dx, x.dy));
    return path;
  }
}
class SfCubicChartClipper extends CustomClipper<Path>{
  SfCubicChartClipper({required this.controlPoints,CatmullRomSpline? catmullRomSpline,this.dotFn}):catmullRomSpline=catmullRomSpline??SfCubicPath.getCatmullRomSpline(controlPoints);
  List<Offset> controlPoints;
  CatmullRomSpline catmullRomSpline;
  Offset Function(Size size,Offset dot)? dotFn;
  
  Path getClip(Size size){
    final dots = SfCubicPath.getDots(catmullRomSpline,size).map((x) => dotFn?.call(size,x)??x).toList();
    return SfCubicPath.getPath(dots)
      ..lineTo(dots.last.dx,size.height)
      ..lineTo(dots.first.dx,size.height)
      ..close();
  }
  bool shouldReclip(covariant CustomClipper<Path> oldClipper){
    var oldie = oldClipper as SfCubicChartClipper;
    return controlPoints.length!=oldie.controlPoints.length || this!=oldie;
  }
}
