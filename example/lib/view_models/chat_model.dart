import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/services/chat_manager.dart';
import 'package:social_foundation_example/services/event_manager.dart';
import 'package:social_foundation_example/states/chat_state.dart';
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
  Future<void> _sendMessage({@required String msg,@required String msgType,Map attribute}) async {
    await ChatManager.instance.sendMsg(convId:conversation.convId,msg:msg,msgType:msgType,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  void _onMessageEvent(MessageEvent event){
    if(event.isNew){
      list.insert(0,event.message);
      ChatState.instance.convRead(conversation);
    }
    notifyListeners();
  }
  void _onTapSend() async {
    if(inputModel.textEditingController.text.isEmpty) return;
    await _sendMessage(msg:inputModel.textEditingController.text,msgType: MessageType.text);
    inputModel.textEditingController.clear();
  }
  void _onPickImage(File image) async {
    var attribute = {
      'path': image.path
    };
    return _sendMessage(msg:image.path,msgType:MessageType.image,attribute:attribute);
  }
  void _onRecordVoice(String path,int duration) async {
    var data = {
      'url': '',
      'duration': duration
    };
    var attribute = {
      'path': path,
    };
    return _sendMessage(msg:json.encode(data),msgType:MessageType.voice,attribute:attribute);
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
      
      await Message.insertAll(messages);
      ChatState.instance.convRead(conversation);
    }
    _messageSubscription = GetIt.instance<EventBus>().on<MessageEvent>().listen(_onMessageEvent);
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