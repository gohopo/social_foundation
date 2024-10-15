import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfNinePatchImage extends StatelessWidget{
  SfNinePatchImage({
    Key? key,
    required this.image,
    required this.centerSlice,
    this.color,
    this.child
  }):super(key:key);
  final ImageProvider? image;
  final EdgeInsets centerSlice;
  final Color? color;
  final Widget? child;

  @override
  Widget build(context) => SfProvider<SfNinePatchImageModel>(
    model: SfNinePatchImageModel(this),
    builder: (_,model,__) => CustomPaint(
      painter: SfNinePatchImagePainter(model.image?.image,centerSlice,color),
      child: RepaintBoundary(
        child: child,
      ),
    )
  );
}
class SfNinePatchImageModel extends SfViewState{
  SfNinePatchImageModel(this.widget);
  late SfNinePatchImage widget;
  ImageStream? _imageStream;
  ImageInfo? image;

  void _resolveImage(){
    final ImageStream? newImageStream = widget.image?.resolve(ImageConfiguration.empty);
    if(newImageStream?.key != _imageStream?.key){
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream?.addListener(listener);
    }
  }
  void _handleImage(ImageInfo value, bool synchronousCall){
    if(image == value) return;
    if(image!=null && image?.isCloneOf(value)==true){
      value.dispose();
      return;
    }
    image?.dispose();
    image = value;
    if(!synchronousCall) notifyListeners();
  }

  Future initData() async {
    _resolveImage();
  }
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(
      _handleImage,
    ));
    image?.dispose();
    image = null;
    super.dispose();
  }
  void onRefactor(SfViewState newState){
    var model = newState as SfNinePatchImageModel;
    if(!(widget.image==model.widget.image && widget.centerSlice==model.widget.centerSlice)){
      widget = model.widget;
      _resolveImage();
    }
  }
}

class SfNinePatchImagePainter extends CustomPainter{
  SfNinePatchImagePainter(this.image,EdgeInsets centerSlice,this.color):centerSlice=centerSlice/ScreenUtil().pixelRatio!;
  ui.Image? image;
  EdgeInsets centerSlice;
  Color? color;
  @override
  void paint(Canvas canvas, Size size) {
    if(image == null) return;
    Size imageSize = Size(image!.width.toDouble(),image!.height.toDouble())/ScreenUtil().pixelRatio!;
    final Paint paint = Paint()..isAntiAlias=false;
    if(color!=null) paint.colorFilter = ColorFilter.mode(color!,BlendMode.srcIn);
    canvas.save();
    //宽分三列
    if(size.width>imageSize.width && size.height<=imageSize.height) drawImageHorizontal(canvas, size, imageSize, paint);
    //高分三层
    else if(size.width<=imageSize.width && size.height>imageSize.height) drawImageVertical(canvas, size, imageSize, paint);
    //九宫格拉伸
    else if(size.width>imageSize.width && size.height>imageSize.height) drawImageNinePatch(canvas, size, imageSize, paint);
    //画图像缩放
    else drawImageScale(canvas,0,0,size.width,size.height,0,0,imageSize.width,imageSize.height,paint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    var painter = oldDelegate as SfNinePatchImagePainter;
    return painter.image != image;
  }
  void drawImageScale(Canvas canvas,double x,double y,double width,double height,double xSrc,double ySrc,double cxSrc,double cySrc,Paint paint){
    canvas.drawImageRect(image!,Rect.fromLTWH(xSrc*ScreenUtil().pixelRatio!,ySrc*ScreenUtil().pixelRatio!,cxSrc*ScreenUtil().pixelRatio!,cySrc*ScreenUtil().pixelRatio!),Rect.fromLTWH(x,y,width,height),paint);
  }
  void drawImageHorizontal(Canvas canvas,Size size,Size imageSize,Paint paint){
		//左
		drawImageScale(canvas,0,0,centerSlice.left,size.height
      ,0,0,centerSlice.left,imageSize.height,paint);
		//中
		drawImageScale(canvas,centerSlice.left,0,size.width-centerSlice.horizontal,size.height
			,centerSlice.left,0,imageSize.width-centerSlice.horizontal,imageSize.height,paint);
		//右
		drawImageScale(canvas,size.width-centerSlice.right,0,centerSlice.right,size.height
			,imageSize.width-centerSlice.right,0,centerSlice.right,imageSize.height,paint);
  }
  void drawImageVertical(Canvas canvas,Size size,Size imageSize,Paint paint){
		//上
		drawImageScale(canvas,0,0,size.width,centerSlice.top
			,0,0,imageSize.width,centerSlice.top,paint);
		//中
		drawImageScale(canvas,0,centerSlice.top,size.width,size.height-centerSlice.vertical
			,0,centerSlice.top,imageSize.width,imageSize.height-centerSlice.vertical,paint);
		//下
		drawImageScale(canvas,0,size.height-centerSlice.bottom,size.width,centerSlice.bottom
			,0,imageSize.height-centerSlice.bottom,imageSize.width,centerSlice.bottom,paint);
  }
  void drawImageNinePatch(Canvas canvas,Size size,Size imageSize,Paint paint){
		//左上
		drawImageScale(canvas,0,0,centerSlice.left,centerSlice.top
			,0,0,centerSlice.left,centerSlice.top,paint);
		//上
		drawImageScale(canvas,centerSlice.left,0,size.width-centerSlice.horizontal,centerSlice.top
			,centerSlice.left,0,imageSize.width-centerSlice.horizontal,centerSlice.top,paint);
		//右上
		drawImageScale(canvas,size.width-centerSlice.right,0,centerSlice.right,centerSlice.top
			,imageSize.width-centerSlice.right,0,centerSlice.right,centerSlice.top,paint);
		//左中
		drawImageScale(canvas,0,centerSlice.top,centerSlice.left,size.height-centerSlice.vertical
			,0,centerSlice.top,centerSlice.left,imageSize.height-centerSlice.vertical,paint);
		//中
		drawImageScale(canvas,centerSlice.left,centerSlice.top,size.width-centerSlice.horizontal,size.height-centerSlice.vertical
			,centerSlice.left,centerSlice.top,imageSize.width-centerSlice.horizontal,imageSize.height-centerSlice.vertical,paint);
		//右中
		drawImageScale(canvas,size.width-centerSlice.right,centerSlice.top,centerSlice.right,size.height-centerSlice.vertical
			,imageSize.width-centerSlice.right,centerSlice.top,centerSlice.right,imageSize.height-centerSlice.vertical,paint);
		//左下
		drawImageScale(canvas,0,size.height-centerSlice.bottom,centerSlice.left,centerSlice.bottom
			,0,imageSize.height-centerSlice.bottom,centerSlice.left,centerSlice.bottom,paint);
		//中下
		drawImageScale(canvas,centerSlice.left,size.height-centerSlice.bottom,size.width-centerSlice.horizontal,centerSlice.bottom
			,centerSlice.left,imageSize.height-centerSlice.bottom,imageSize.width-centerSlice.horizontal,centerSlice.bottom,paint);
		//右下
		drawImageScale(canvas,size.width-centerSlice.right,size.height-centerSlice.bottom,centerSlice.right,centerSlice.bottom
			,imageSize.width-centerSlice.right,imageSize.height-centerSlice.bottom,centerSlice.right,centerSlice.bottom,paint);
  }
}