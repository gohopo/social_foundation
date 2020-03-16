import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/services/chat_manager.dart';
import 'package:social_foundation_example/states/user_state.dart';
import 'package:social_foundation_example/widgets/chat_input.dart';

class ChatModel extends SfRefreshListViewState<Message>{
  Conversation conversation;
  StreamSubscription _messageSubscription;
  ChatInputModel inputModel;
  ScrollController scrollController = ScrollController();

  ChatModel({@required this.conversation}){
    inputModel = ChatInputModel(onTapSend:_onTapSend,onPickImage: _onPickImage,onRecordVoice: _onRecordVoice);
  }
  Future<void> _sendMessage({String msg,@required String msgType,Map msgExtra,Map attribute}) async {
    await ChatManager.instance.sendMsg(convId:conversation.convId,msg:msg,msgType:msgType,msgExtra:msgExtra,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  void _onMessageEvent(SfMessageEvent event){
    if(event.message.convId != conversation.convId) return;
    if(event.isNew){
      list.insert(0,event.message);
      ChatManager.instance.convRead(conversation.convId);
    }
    notifyListeners();
  }
  void _onTapSend() async {
    if(inputModel.textEditingController.text.isEmpty) return;
    await _sendMessage(msg:inputModel.textEditingController.text,msgType: SfMessageType.text);
    inputModel.textEditingController.clear();
  }
  void _onPickImage(File image) async {
    var filePath = await SfAliyunOss.cacheFile(SfMessageType.image,image.path,prefix: 'chat',encrypt: 1);
    var attribute = {
      'filePath': filePath
    };
    return _sendMessage(msgType:SfMessageType.image,attribute:attribute);
  }
  void _onRecordVoice(String path,int duration) async {
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
      var messages = await ChatManager.instance.queryMessages(conversation.convId, conversation.unreadMessagesCount);
      messages = messages.where((message) => list.every((data) => data.msgId!=message.msgId)).toList();
      list.insertAll(0,messages);
      list.sort((a,b) => b.timestamp-a.timestamp);
      notifyListeners();
      
      await SfMessage.insertAll(messages);
      ChatManager.instance.convRead(conversation.convId);
    }
    _messageSubscription = GetIt.instance<EventBus>().on<SfMessageEvent>().listen(_onMessageEvent);
  }
  @override
  Future<List<Message>> loadData(bool refresh) {
    return Message.queryAll(UserState.instance.curUserId,conversation.convId, max(conversation.unreadMessagesCount, 20), refresh ? 0 : list.length);
  }
  @override
  void dispose(){
    _messageSubscription?.cancel();
    super.dispose();
  }
}