import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/widget/chat_input.dart';
import 'package:social_foundation_example/widget/message_item.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    Key key,
    @required this.conversation
  }) : super(key:key);
  final Conversation conversation;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> _messages = [];
  StreamSubscription _messageSubscription;

  void _onMessageReceived(Message message){
    setState((){
      _messages.insert(0, message);
    });
  }
  void loadMore() async {
    var result = await Message.queryAll(widget.conversation.convId, 20, _messages.length);
    _messages.addAll(result);
  }

  @override
  void initState(){
    loadMore();
    _messageSubscription = GetIt.instance<EventBus>().on<Message>().listen(_onMessageReceived);
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
        buildMessages(),
        buildInput()
      ],),
    );
  }
  Widget buildMessages(){
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context,index) => MessageItemWidget(message: _messages[index])
    );
  }
  Widget buildInput(){
    return ChatInput();
  }
}