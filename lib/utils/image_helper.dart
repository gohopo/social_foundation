import 'dart:typed_data';
import 'dart:ui' as ui show Image,ImageByteFormat,window;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SfImageHelper{
  static Future<ui.Image> captureToImage(GlobalKey key,{double pixelRatio}){
    pixelRatio ??= ui.window.devicePixelRatio;
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    return boundary.toImage(pixelRatio:pixelRatio);
  }
  static Future<Uint8List> captureToBytes(GlobalKey key,{double pixelRatio,ui.ImageByteFormat format}) async {
    var image = await captureToImage(key,pixelRatio:pixelRatio);
    var bytes = await image.toByteData(format:format ?? ui.ImageByteFormat.png);
    return bytes.buffer.asUint8List();
  }
}