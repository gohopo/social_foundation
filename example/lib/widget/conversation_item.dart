import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/config/router_manager.dart';
import 'package:social_foundation_example/model/conversation.dart';

class ConversationItemWidget extends StatelessWidget{
  ConversationItemWidget({
    this.conversation,
    this.onTap
  }) : super(key: ValueKey(conversation.convId));

  final Conversation conversation;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? (){
        Navigator.of(context).pushNamed(RouteName.Chat,arguments: {conversation:conversation});
      },
      child: Ink(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Avatar(width: 45,height:45,image: AssetImage('assets/images/bird.png'),),
            Expanded(
              flex: 1,
              child: Text(conversation.lastMessage.message),
            ),
            Text(DateTime.fromMillisecondsSinceEpoch(conversation.lastMessageAt).toString().substring(0,19))
          ],
        ),
      ),
    );
  }
}