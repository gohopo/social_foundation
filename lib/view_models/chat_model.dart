import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/aliyun_helper.dart';
import 'package:social_foundation/widgets/chat_input.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatModel<TConversation extends SfConversation,TMessage extends SfMessage> extends SfRefreshListViewState<TMessage>{
  SfChatModel({this.conversation,this.name='',this.anonymous=false}){
    onInitInputModel();
  }
  TConversation? conversation;
  String name;
  bool anonymous;
  SfClientResumingEvent _clientResumingEvent = SfClientResumingEvent();
  SfMessageEvent _messageEvent = SfMessageEvent();
  SfMessageClearEvent _clearEvent = SfMessageClearEvent();
  late SfChatInputModel inputModel;
  ScrollController scrollController = ScrollController();
  @override
  Future initData() async {
    _clientResumingEvent.listen((event) => onClientResuming());
    _clearEvent.listen((event){
      list.clear();
      notifyListeners();
    },onWhere:(event) => event.convId==conversation?.convId);
    await super.initData();
    listenMessageEvent();
  }
  @override
  void dispose(){
    _clientResumingEvent.dispose();
    disposeMessageEvent();
    _clearEvent.dispose();
    super.dispose();
  }
  Future listenMessageEvent() async {
    convRead();
    _messageEvent.listen(onMessageEvent,onWhere:onMessageEventWhere);
  }
  void disposeMessageEvent() => _messageEvent.dispose();
  Future sendMessage({String? msg,required String msgType,Map? msgExtra,Map? attribute}) async {
    await SfLocatorManager.chatManager.sendMsg(convId:conversation!.convId,msg:await filterKeyword(msg,msgType),msgType:msgType,msgExtra:msgExtra,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  Future<String?> filterKeyword(String? msg,String msgType) async => SfLocatorManager.appState.filterKeyword(msg);
  bool onMessageEventWhere(SfMessageEvent event) => event.message?.convId==conversation?.convId;
  void onMessageEvent(SfMessageEvent event){
    var message = event.message as TMessage;
    if(event.isNew){
      list.insert(0,message);
      if(list.length>1 && message.timestamp<list[1].timestamp) list.sort((a,b) => b.timestamp-a.timestamp);
      if(!message.fromOwner) convRead();
    }
    else{
      var index = list.indexWhere((data) => data.equalTo(message));
      if(index != -1) list[index] = message;
    }
    notifyListeners();
  }
  void convRead() => conversation?.read();
  Future onUnreadMessages(List<TMessage> messages) async {}
  void onInitInputModel(){
    inputModel = SfChatInputModel(onTapSend:onTapSend,onPickImage:onPickImage,onRecordVoice:onRecordVoice,onAccessoryChanged:onAccessoryChanged);
  }
  void onSendError(dynamic error){
    SfLocatorManager.appState.showError(error);
  }
  void onSendTextError(dynamic error) => onSendError(error);
  void onSendImageError(dynamic error) => onSendError(error);
  void onSendVoiceError(dynamic error) => onSendError(error);
  void onTapSend() async {
    try{
      if(inputModel.textEditingController.text.isEmpty) return;
      await sendMessage(msg:inputModel.textEditingController.text,msgType: SfMessageType.text);
      inputModel.textEditingController.clear();
    }
    catch(error){
      onSendTextError(error);
    }
  }
  void onPickImage(File image) async {
    try{
      var filePath = await SfAliyunOss.cacheFile(SfMessageType.image,image.path,prefix: 'chat',encrypt: 1);
      var attribute = {
        'filePath': filePath,
        'fileDir': SfMessageType.image
      };
      await sendMessage(msgType:SfMessageType.image,attribute:attribute);
    }
    catch(error){
      onSendImageError(error);
    }
  }
  void onRecordVoice(String path,int duration) async {
    try{
      var filePath = await SfAliyunOss.cacheFile(SfMessageType.voice,path,prefix:'chat');
      Map msgExtra = {
        'duration': duration
      };
      Map attribute = {
        'filePath': filePath,
        'fileDir': SfMessageType.voice
      };
      await sendMessage(msgType:SfMessageType.voice,msgExtra:msgExtra,attribute:attribute);
    }
    catch(error){
      onSendVoiceError(error);
    }
  }
  Future deleteMessage(TMessage message) async {
    await SfMessage.delete(message.id!);
    list.removeWhere((data) => data.id==message.id);
    notifyListeners();
  }
  void onAccessoryChanged(SfChatInputModel model){}
  void onClientResuming(){}
}