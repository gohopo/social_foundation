import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/chat_manager.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/chat_input.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatModel<TConversation extends SfConversation,TMessage extends SfMessage> extends SfRefreshListViewState<TMessage>{
  TConversation? conversation;
  String name;
  bool anonymous;
  SfClientResumingEvent _clientResumingEvent = SfClientResumingEvent();
  SfMessageEvent _messageEvent = SfMessageEvent();
  late SfChatInputModel inputModel;
  ScrollController scrollController = ScrollController();

  SfChatModel(Map args):conversation=args['conversation'],name=args['name']??'',anonymous=args['anonymous']??false{
    onInitInputModel();
  }
  Future sendMessage({String? msg,required String msgType,Map? msgExtra,Map? attribute}) async {
    await GetIt.instance<SfChatManager>().sendMsg(convId:conversation!.convId,msg:await filterKeyword(msg,msgType),msgType:msgType,msgExtra:msgExtra,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  Future<String?> filterKeyword(String? msg,String msgType) async => SfLocatorManager.appState.filterKeyword(msg);
  bool onMessageEventWhere(SfMessageEvent event) => event.message?.convId==conversation?.convId;
  void onMessageEvent(SfMessageEvent event){
    var message = event.message as TMessage;
    if(event.isNew){
      list.insert(0,message);
      if(!message.fromOwner) convRead();
    }
    else{
      var index = list.indexWhere((data) => data.equalTo(message));
      if(index != -1) list[index] = message;
    }
    notifyListeners();
  }
  Future queryUnreadMessages() async {
    _messageEvent.dispose();
    if(conversation==null) return;
    if(conversation!.unreadMessagesCount > 0){
      List<TMessage> messages = await GetIt.instance<SfChatManager>().queryMessages(conversation!.convId, conversation!.unreadMessagesCount) as List<TMessage>;
      onUnreadMessages(messages);
      messages = messages.where((message) => list.every((data) => data.msgId!=message.msgId)).toList();
      list.insertAll(0,messages);
      list.sort((a,b) => b.timestamp-a.timestamp);
      notifyListeners();
      
      await SfMessage.insertAll(messages);
      convRead();
    }
    _messageEvent.listen(onMessageEvent,onWhere:onMessageEventWhere);
  }
  void convRead() => SfLocatorManager.chatState.read(conversation!.convId);
  void onUnreadMessages(List<TMessage> messages){}
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
      return sendMessage(msgType:SfMessageType.image,attribute:attribute);
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
      return sendMessage(msgType:SfMessageType.voice,msgExtra:msgExtra,attribute:attribute);
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
  void onClientResuming() async {
    await conversation?.queryUnreadMessagesCount();
    queryUnreadMessages();
  }

  @override
  Future initData() async {
    _clientResumingEvent.listen((event) => onClientResuming());
    await super.initData();
    await queryUnreadMessages();
  }
  @override
  void dispose(){
    _clientResumingEvent.dispose();
    _messageEvent.dispose();
    super.dispose();
  }
}