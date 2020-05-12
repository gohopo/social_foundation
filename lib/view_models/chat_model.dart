import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/chat_manager.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/chat_input.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatModel<TConversation extends SfConversation,TMessage extends SfMessage> extends SfRefreshListViewState<TMessage>{
  TConversation conversation;
  SfMessageEvent _messageEvent;
  SfChatInputModel inputModel;
  ScrollController scrollController = ScrollController();

  SfChatModel(Map args) : conversation=args['conversation']{
    inputModel = SfChatInputModel(onTapSend:onTapSend,onPickImage: onPickImage,onRecordVoice: onRecordVoice);
  }
  Future<void> _sendMessage({String msg,@required String msgType,Map msgExtra,Map attribute}) async {
    await GetIt.instance<SfChatManager>().sendMsg(convId:conversation.convId,msg:msg,msgType:msgType,msgExtra:msgExtra,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  void onMessageEvent(SfMessageEvent event){
    if(event.message.convId != conversation.convId) return;
    if(event.isNew){
      list.insert(0,event.message);
      GetIt.instance<SfChatManager>().convRead(conversation.convId);
    }
    notifyListeners();
  }
  void onTapSend() async {
    if(inputModel.textEditingController.text.isEmpty) return;
    await _sendMessage(msg:inputModel.textEditingController.text,msgType: SfMessageType.text);
    inputModel.textEditingController.clear();
  }
  void onPickImage(File image) async {
    var filePath = await SfAliyunOss.cacheFile(SfMessageType.image,image.path,prefix: 'chat',encrypt: 1);
    var attribute = {
      'filePath': filePath
    };
    return _sendMessage(msgType:SfMessageType.image,attribute:attribute);
  }
  void onRecordVoice(String path,int duration) async {
    var filePath = await SfAliyunOss.cacheFile(SfMessageType.voice,path,prefix:'chat');
    Map msgExtra = {
      'duration': duration
    };
    Map attribute = {
      'filePath': filePath
    };
    return _sendMessage(msgType:SfMessageType.voice,msgExtra:msgExtra,attribute:attribute);
  }

  @override
  Future<void> initData() async {
    await super.initData();
    if(conversation.unreadMessagesCount > 0){
      List<TMessage> messages = await GetIt.instance<SfChatManager>().queryMessages(conversation.convId, conversation.unreadMessagesCount);
      messages = messages.where((message) => list.every((data) => data.msgId!=message.msgId)).toList();
      list.insertAll(0,messages);
      list.sort((a,b) => b.timestamp-a.timestamp);
      notifyListeners();
      
      await SfMessage.insertAll(messages);
      GetIt.instance<SfChatManager>().convRead(conversation.convId);
    }
    _messageEvent.listen(onMessageEvent);
  }
  @override
  void dispose(){
    _messageEvent?.dispose();
    super.dispose();
  }
}