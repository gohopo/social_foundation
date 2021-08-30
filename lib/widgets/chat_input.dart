import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_foundation/widgets/audio_widget.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfChatInput extends StatelessWidget {
  SfChatInput({
    Key key,
    this.model,
    this.backgroundColor = const Color.fromARGB(255,37,38,51),
    this.editorBackgroundColor = const Color.fromARGB(255,48,50,66),
    this.editorColor = Colors.white,
    this.accessoryHeight = 260
  }) : super(key:key);
  final SfChatInputModel model;
  final Color backgroundColor;
  final Color editorBackgroundColor;
  final Color editorColor;
  final double accessoryHeight;
  
  Widget buildEditor(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal:11),
      decoration: BoxDecoration(
        color: editorBackgroundColor,
        borderRadius: BorderRadius.circular(16.5)
      ),
      child: TextField(
        controller: model.textEditingController,
        focusNode: model.focusNode,
        textInputAction: model.textInputAction,
        onEditingComplete: model.onTapSend,
        style: TextStyle(fontSize:16,color:editorColor),
        decoration: InputDecoration(
          hintText: '说点什么吧~',
          hintStyle: TextStyle(fontSize:16,color:Color.fromRGBO(172,175,192,0.8)),
          contentPadding: EdgeInsets.symmetric(vertical:14),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      )
    );
  }
  Widget buildSend(BuildContext context){
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left:15),
        child: Icon(Icons.send,color:Color.fromARGB(255,159,162,178)),
      ),
      onTap: model.onTapSend,
    );
  }
  Widget buildToolbar(BuildContext context){
    var list = buildMenuList(context);
    return Container(
      padding: EdgeInsets.only(bottom:16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: list.asMap().keys.map((index) => GestureDetector(
            child: list[index],
            onTap: () => model.onTapMenu(index),
        )).toList(),
      ),
    );
  }
  List<Widget> buildMenuList(BuildContext context){
    return [
      Icon(Icons.keyboard_voice,color: model.curAccessory==0?Colors.blue:null),
      Icon(Icons.photo_album),
      Icon(Icons.photo_camera),
    ];
  }
  Widget buildAccessoryContainer(BuildContext context){
    Widget accessory = buildAccessory(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: accessory!=null ? accessoryHeight : 0,
      child: accessory
    );
  }
  Widget buildAccessory(BuildContext context){
    if(model.curAccessory == 0){
      return Center(
        child: SfAudioRecorderConsumer(
          onStartRecord: model.onStartRecord,
          onStopRecord: model.onStopRecord,
          child: ClipOval(
            child: Container(
              color: Colors.blue,
              width: 120,
              height: 120,
              alignment: AlignmentDirectional.center,
              child: Text(model.recorderTips,style: TextStyle(fontSize: 17.0, color: Colors.white)),
            ),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SfProvider<SfChatInputModel>(
      model: model,
      builder: (context,model,child) => Container(
        color: backgroundColor,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: buildEditor(context)
                ),
                buildSend(context)
              ]
            )
          ),
          buildToolbar(context),
          buildAccessoryContainer(context)
        ]),
      ),
    );
  }
}

class SfChatInputModel extends SfViewState {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  TextInputAction textInputAction = TextInputAction.send;
  int _curAccessory = -1;
  String recorderTips = '按住 说话';
  VoidCallback onTapSend;
  double imageMaxWidth = 1000;
  double imageMaxHeight = 1000;
  int imageQuality = 75;
  final void Function(File image) onPickImage;
  final void Function(String path,int duration) onRecordVoice;
  final void Function(SfChatInputModel model) onAccessoryChanged;
  bool editorHasFocus = false;
  SfChatInputModel({
    this.onTapSend,
    this.onPickImage,
    this.onRecordVoice,
    this.onAccessoryChanged
  });

  int get curAccessory => _curAccessory;
  void changeAccessory(int curAccessory){
    if(curAccessory!=-1 && focusNode.hasFocus){
      focusNode.unfocus();
      editorHasFocus = false;
    }
    else if(_curAccessory == curAccessory){
      curAccessory = -1;
    }
    _curAccessory = curAccessory;
    notifyListeners();
    onAccessoryChanged?.call(this);
  }
  void onTapMenu(int index){
    changeAccessory(index);
    if(index == 1) onTapPhoto(ImageSource.gallery);
    else if(index == 2) onTapPhoto(ImageSource.camera);
  }
  void onTapPhoto(ImageSource source) async {
    var file = await ImagePicker().getImage(source:source,maxWidth:imageMaxWidth,maxHeight:imageMaxHeight,imageQuality:imageQuality);
    var image = File(file.path);
    if(image==null || onPickImage==null) return;
    onPickImage(image);
  }
  void onStartRecord(){
    recorderTips = '松开 结束';
    notifyListeners();
  }
  void onStopRecord(String path,int duration,bool isCancelled){
    recorderTips = '按住 说话';
    notifyListeners();
    if(!isCancelled) onRecordVoice(path,duration);
  }

  @override
  Future initData() async {
    focusNode.addListener((){
      editorHasFocus = focusNode.hasFocus;
      if(focusNode.hasFocus){
        changeAccessory(-1);
      }
    });
  }
}