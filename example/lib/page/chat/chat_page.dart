import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/widget/message_item.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> _messages = [];
  StreamSubscription _messageSubscription;

  void _onMessageReceived(ChatMessage message){
    setState((){
      _messages.insert(0, message);
    });
  }

  @override
  void initState(){
    _messageSubscription = GetIt.instance<EventBus>().on<ChatMessage>().listen(_onMessageReceived);
    super.initState();
  }
  @override
  void dispose(){
    _messageSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天')),
      body: Column(children: <Widget>[
        ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context,index) => MessageItemWidget(message: _messages[index])
        ),
        
      ],),
    );
  }
}