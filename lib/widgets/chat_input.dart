import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_foundation/widgets/audio_widget.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfChatInput extends StatelessWidget {
  final SfChatInputModel model;

  SfChatInput({
    Key key,
    this.model
  }) : super(key:key);
  Widget buildEditor(){
    return TextField(
      controller: model.textEditingController,
      focusNode: model.focusNode,
      decoration: InputDecoration(
        hintText: '请输入消息...'
      ),
    );
  }
  Widget buildSend(){
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical:10),
        child: Icon(Icons.send),
      ),
      onTap: model.onTapSend,
    );
  }
  Widget buildToolbar(){
    return Container(
      padding: EdgeInsets.symmetric(vertical:5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.keyboard_voice,color: model.curAccessory==0?Colors.blue:null),
            onTap: () => model.changeAccessory(0),
          ),
          GestureDetector(
            child: Icon(Icons.photo_album),
            onTap: () {
              model.changeAccessory(1);
              onTapPhoto(ImageSource.gallery);
            },
          ),
          GestureDetector(
            child: Icon(Icons.photo_camera),
            onTap: () {
              model.changeAccessory(2);
              onTapPhoto(ImageSource.camera);
            },
          )
        ],
      ),
    );
  }
  Widget buildAccessory(){
    Widget accessory;
    if(model.curAccessory == 0){
      accessory = Center(
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: accessory!=null ? 260 : 0,
      child: accessory
    );
  }
  void onTapPhoto(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    if(image==null || model.onPickImage==null) return;
    model.onPickImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return SfProviderWidget<SfChatInputModel>(
      model: model,
      builder: (context,model,child) => Column(children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal:14,vertical:5),
          child: Row(children: <Widget>[
            Expanded(
              child: buildEditor()
            ),
            buildSend()
          ]),
        ),
        buildToolbar(),
        buildAccessory()
      ]),
    );
  }
}

class SfChatInputModel extends SfViewState {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  int _curAccessory = -1;
  String recorderTips = '按住 说话';
  VoidCallback onTapSend;
  final void Function(File image) onPickImage;
  final void Function(String path,int duration) onRecordVoice;
  SfChatInputModel({
    this.onTapSend,
    this.onPickImage,
    this.onRecordVoice
  }){
    initData();
  }

  int get curAccessory => _curAccessory;
  void changeAccessory(int curAccessory){
    if(curAccessory!=-1 && focusNode.hasFocus){
      focusNode.unfocus();
    }
    else if(_curAccessory == curAccessory){
      curAccessory = -1;
    }
    _curAccessory = curAccessory;
    notifyListeners();
  }
  void onStartRecord(){
    recorderTips = '松开 结束';
    notifyListeners();
  }
  void onStopRecord(String path,int duration){
    recorderTips = '按住 说话';
    notifyListeners();
    onRecordVoice(path,duration);
  }

  @override
  Future initData() async {
    focusNode.addListener((){
      if(focusNode.hasFocus){
        changeAccessory(-1);
      }
    });
  }
}