import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image,ImageByteFormat,window;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SfImageHelper{
  static Future<ui.Image> captureToImage(GlobalKey key,{double? pixelRatio}){
    pixelRatio ??= ui.window.devicePixelRatio;
    var boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio:pixelRatio);
  }
  static Future<Uint8List?> captureToBytes(GlobalKey key,{double? pixelRatio,ui.ImageByteFormat? format}) async {
    var image = await captureToImage(key,pixelRatio:pixelRatio);
    var bytes = await image.toByteData(format:format ?? ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
  static Future<ui.Image> convertProviderToImage(ImageProvider provider,{ImageConfiguration? configuration}){
    var completer = Completer<ui.Image>();
    var stream = provider.resolve(configuration??ImageConfiguration.empty);
    ImageStreamListener listener = ImageStreamListener((image,synchronousCall) => completer.complete(image.image),onError: completer.completeError);
    stream.addListener(listener);
    return completer.future..whenComplete(() => stream.removeListener(listener));
  }
  static Future<Uint8List?> convertProviderToBytes(ImageProvider provider,{ImageConfiguration? configuration,ui.ImageByteFormat? format}) async {
    var image = await convertProviderToImage(provider,configuration:configuration);
    var bytes = await image.toByteData(format:format??ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
  static Future<File?> pickImage({required ImageSource source,double? maxWidth,double? maxHeight,int? imageQuality,int maxFileSize=6,CameraDevice preferredCameraDevice=CameraDevice.rear}) async {
    File? file;
    try{
      var status = await SfLocatorManager.appState.getPermission(source==ImageSource.gallery?Permission.photos:Permission.camera);
      if(!status.isGranted) throw '!';
      var pickedFile = await ImagePicker().pickImage(
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
  static Future<List<File>> pickImages({int maxFileSize=6,int? maxLength=9}) async {
    try{
      var status = await SfLocatorManager.appState.getPermission(Permission.photos);
      if(!status.isGranted) throw '!';
      var assets = await AssetPicker.pickAssets(
        SfLocatorManager.routerManager.navigator!.context,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxLength ?? 9,
          requestType: RequestType.image,
          selectPredicate: (context,asset,isSelected) async {
            if(isSelected || maxFileSize<=0) return true;
            if(!isSelected && maxFileSize>0){
              var file = await asset.file;
              if(file!=null){
                var bytes = await file.readAsBytes();
                if(bytes.lengthInBytes > maxFileSize*1024*1024){
                  SfLocatorManager.appState.showError('文件大小超出${maxFileSize}M限制');
                  return false;
                }
              }
            }
            return true;
          },
        ),
      );
      var files = await Future.wait<File?>(assets?.map((x) => x.file)??[]);
      return files.where((x)=>x!=null).cast<File>().toList();
    }
    catch(error){
      throw '没有相册权限';
    }
  }
  static Future saveImage(Uint8List imageBytes,{int quality=80,String? name,bool isReturnImagePathOfIOS=false}) async {
    var status = await SfLocatorManager.appState.getPermission(Permission.storage);
    if(!status.isGranted) throw '没有存储权限!';
    return ImageGallerySaver.saveImage(imageBytes,quality:quality,name:name,isReturnImagePathOfIOS:isReturnImagePathOfIOS);
  }
}