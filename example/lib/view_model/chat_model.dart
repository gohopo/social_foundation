import 'dart:async';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/service/chat_manager.dart';
import 'package:social_foundation_example/service/event_manager.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:social_foundation_example/state/view_state.dart';
import 'package:social_foundation_example/widget/chat_input.dart';

class ChatModel extends RefreshListViewState<Message>{
  Conversation conversation;
  StreamSubscription _messageSubscription;
  ChatInputModel inputModel;
  ScrollController scrollController = ScrollController();

  ChatModel({@required this.conversation}){
    inputModel = ChatInputModel(onTapSend:_onTapSend,onPickImage: _onPickImage);
  }
  Future<void> _sendMessage({@required String msg,@required String msgType,Map attribute}) async {
    await ChatManager.instance.sendMsg(convId:conversation.convId,msg:msg,msgType:msgType,attribute:attribute);
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
  void _onMessageEvent(MessageEvent event){
    if(event.isNew){
      list.insert(0,event.message);
    }
    notifyListeners();
  }
  void _onTapSend() async {
    if(inputModel.textEditingController.text.isEmpty) return;
    await _sendMessage(msg:inputModel.textEditingController.text,msgType: MessageType.text);
    inputModel.textEditingController.clear();
  }
  void _onPickImage(File image) async {
    Map attribute = {
      'path': image.path
    };
    return _sendMessage(msg:image.path,msgType:MessageType.image,attribute:attribute);
  }

  @override
  void initData(){
    _messageSubscription = GetIt.instance<EventBus>().on<MessageEvent>().listen(_onMessageEvent);
    super.initData();
  }
  @override
  Future<List<Message>> loadData(bool refresh) {
    return Message.queryAll(UserState.instance.curUserId,conversation.convId, 20, refresh ? 0 : list.length);
  }
  @override
  void dispose(){
    _messageSubscription.cancel();
    super.dispose();
  }
}