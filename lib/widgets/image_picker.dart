import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SfImagePicker extends StatelessWidget{
  SfImagePicker({
    Key key,
    @required this.onPickImage
  }) : super(key:key);
  final Function(File image) onPickImage;

  static Future<File> pickImage(){
    var completer = Completer<File>();

    BotToast.showWidget(toastBuilder: (cancelFunc) => SfImagePicker(
      onPickImage: (image){
        completer.complete(image);
        cancelFunc();
      }
    ));

    return completer.future;
  }
  Widget buildItem(BuildContext context,String title,ImageSource source){
    return GestureDetector(
      onTap: () => _onPickImage(source),
      child: Container(
        width: 250,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(title,style:TextStyle(fontSize: 16,color: Theme.of(context).primaryColor)),
      ),
    );
  }
  _onPickImage(ImageSource source) async {
    var file;
    if(source != null){
      file = await ImagePicker.pickImage(source: source);
    }
    onPickImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPickImage(null),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildItem(context,'相册',ImageSource.gallery),
              Container(height: 1),
              buildItem(context,'拍照',ImageSource.camera),
            ],
          )
        )
      )
    );
  }
}