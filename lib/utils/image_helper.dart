import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image,ImageByteFormat,window;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static Future<ui.Image> convertProviderToImage(ImageProvider provider,{ImageConfiguration configuration}){
    var completer = Completer<ui.Image>();
    var stream = provider.resolve(configuration??ImageConfiguration.empty);
    ImageStreamListener listener = ImageStreamListener((image,synchronousCall) => completer.complete(image.image),onError: completer.completeError);
    stream.addListener(listener);
    return completer.future..whenComplete(() => stream.removeListener(listener));
  }
  static Future<Uint8List> convertProviderToBytes(ImageProvider provider,{ImageConfiguration configuration,ui.ImageByteFormat format}) async {
    var image = await convertProviderToImage(provider,configuration:configuration);
    var bytes = await image.toByteData(format:format??ui.ImageByteFormat.png);
    return bytes.buffer.asUint8List();
  }
  static Future<File> pickImage({@required ImageSource source,double maxWidth,double maxHeight,int imageQuality,int maxFileSize=6,CameraDevice preferredCameraDevice=CameraDevice.rear}) async {
    File file;
    try{
      var pickedFile = await ImagePicker().getImage(
        source:source,maxWidth:maxWidth,maxHeight:maxHeight,imageQuality:imageQuality,preferredCameraDevice:preferredCameraDevice
      );
      file = pickedFile!=null ? File(pickedFile.path) : null;
    }
    catch(error){
      throw '没有${source==ImageSource.gallery?'相册':'相机'}权限';
    }
    if(file!=null && maxFileSize>0){
      var bytes = await file.readAsBytes();
      if(bytes.lengthInBytes > (maxFileSize*1024*1024)) throw '文件大小超出最大限制';
    }
    return file;
  }
  static Future saveImage(Uint8List imageBytes,{int quality=80,String name,bool isReturnImagePathOfIOS=false}) async {
    var status = await Permission.storage.status;
    if(!status.isGranted) status = await Permission.storage.request();
    if(!status.isGranted) throw '没有存储权限!';
    return ImageGallerySaver.saveImage(imageBytes,quality:quality,name:name,isReturnImagePathOfIOS:isReturnImagePathOfIOS);
  }
}