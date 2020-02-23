import 'package:flutter/material.dart';
import 'package:social_foundation_example/service/router_manager.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/widget/user_widget.dart';

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
        Navigator.of(context).pushNamed(RouteName.Chat,arguments: conversation);
      },
      child: Ink(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            UserConsumer(
              userId: conversation.otherId,
              builder: (context,user,child) => UserAvatar(user: user),
            ),
            Expanded(
              flex: 1,
              child: Text(conversation.lastMessage.msg),
            ),
            Text(DateTime.fromMillisecondsSinceEpoch(conversation.lastMessageAt).toString().substring(0,19))
          ],
        ),
      ),
    );
  }
}