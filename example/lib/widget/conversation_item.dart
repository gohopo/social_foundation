import 'package:date_format/date_format.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 12,vertical:8),
        height: 64,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5,color:Color(0xFFd9d9d9)))
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: UserConsumer(
                userId: conversation.otherId,
                builder: (context,user,child) => Row(children: <Widget>[
                  UserAvatar(user: user,width: 48,height: 48),
                  Padding(padding: EdgeInsets.only(right:12)),
                  Column(children: <Widget>[
                    UserNickName(
                      user: user,
                      style: TextStyle(fontSize: 16.0, color: Color(0xFF353535))
                    ),
                    Padding(padding: EdgeInsets.only(top:8)),
                    Text(
                      conversation.lastMessage.msg,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFFa9a9a9)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                    )
                  ])
                ])
              )
            ),
            Column(children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Text(
                  formatDate(DateTime.fromMillisecondsSinceEpoch(conversation.lastMessageAt), [HH, ':', nn, ':', ss]).toString(),
                  style: TextStyle(fontSize: 14.0, color: Color(0xFFa9a9a9)),
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}