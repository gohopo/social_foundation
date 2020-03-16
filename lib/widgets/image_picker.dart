import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class SfImagePicker extends StatelessWidget{
  SfImagePicker({
    Key key,
    @required this.onPickImage
  }) : super(key:key);
  final Function(File image) onPickImage;

  Widget buildItem(BuildContext context,String title,ImageSource source){
    return InkWell(
      onTap: () => _onPickImage(source),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Text(title,style:TextStyle(color: Theme.of(context).buttonColor)),
      ),
    );
  }
  _onPickImage(ImageSource source) async {
    var file = await ImagePicker.pickImage(source: source);
    onPickImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildItem(context,'相册',ImageSource.gallery),
        buildItem(context,'拍照',ImageSource.camera),
      ],
    );
  }
}