import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/service/chat_manager.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:social_foundation_example/state/view_state.dart';
import 'package:social_foundation_example/widget/chat_input.dart';

class ChatModel extends RefreshListViewState<Message>{
  Conversation conversation;
  StreamSubscription _messageSubscription;
  ChatInputModel inputModel;
  ScrollController scrollController = ScrollController();

  ChatModel({@required this.conversation}){
    inputModel = ChatInputModel(onTapSend:_onTapSend);
  }
  void _onMessageReceived(Message message){
    list.insert(0,message);
    notifyListeners();
  }
  void _onTapSend() async {
    if(inputModel.textEditingController.text.isEmpty) return;
    var message = await ChatManager.instance.sendTextMsg(convId:conversation.convId,msg:inputModel.textEditingController.text);
    _onMessageReceived(message);
    inputModel.textEditingController.clear();
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void initData(){
    _messageSubscription = GetIt.instance<EventBus>().on<Message>().listen(_onMessageReceived);
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