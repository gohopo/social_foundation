import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation_example/state/chat_state.dart';
import 'package:social_foundation_example/widget/conversation_item.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('消息')),
      body: Consumer<ChatState>(
        builder: (context, snapshot, child){
          return ListView.separated(
            itemCount: snapshot.conversations.length,
            itemBuilder: (context,index){
              var conv = snapshot.conversations[index];
              return ConversationItemWidget(conversation: conv);
            },
            separatorBuilder: (context,index) => Divider(color: Colors.green)
          );
        },
      ),
    );
  }
}