import 'package:flutter/material.dart';

class NinePatchImage extends StatelessWidget{
  NinePatchImage({
    Key key,
    @required this.image,
    @required this.imageSize,
    @required this.centerSlice,
    this.padding,
    this.child
  }) : super(key:key);
  final ImageProvider image;
  final Size imageSize;
  final Rect centerSlice;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context){
    return Container(
      padding: padding,
      constraints: BoxConstraints(
        minWidth: imageSize.width,
        minHeight: imageSize.height
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          centerSlice: centerSlice,
        )
      ),
      child: Align(
        widthFactor: 1,
        child: child
      )
    );
  }
}