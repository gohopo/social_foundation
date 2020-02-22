import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:social_foundation_example/state/view_state.dart';

class ChatModel extends RefreshListViewState<Message>{
  Conversation conversation;
  StreamSubscription _messageSubscription;

  ChatModel({@required this.conversation});
  void _onMessageReceived(Message message){
    list.insert(0, message);
    notifyListeners();
  }

  @override
  void initData(){
    _messageSubscription = GetIt.instance<EventBus>().on<Message>().listen(_onMessageReceived);
    super.initData();
  }
  @override
  Future<List<Message>> loadData() {
    return Message.queryAll(UserState.instance.curUserId,conversation.convId, 20, list.length);
  }
  @override
  void dispose(){
    _messageSubscription.cancel();
    super.dispose();
  }
}