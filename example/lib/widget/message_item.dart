import 'package:flutter/material.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/model/user.dart';
import 'package:social_foundation_example/widget/user_widget.dart';

class MessageItemWidget extends StatelessWidget{
  MessageItemWidget({
    this.message,
    this.onTap
  }) : super(key: ValueKey(message.msgId));

  final Message message;
  final GestureTapCallback onTap;

  Widget buildAvatar(User user){
    return UserAvatar(user: user);
  }
  Widget buildNickName(User user){
    return UserNickName(user: user);
  }
  Widget buildBubble(){
    return Text(message.message);
  }

  @override
  Widget build(BuildContext context) {
    return UserConsumer(
      userId: message.fromId,
      builder: (context,user,child) => Row(children: <Widget>[
        buildAvatar(user),
        Column(children: <Widget>[
          buildNickName(user),
          buildBubble()
        ],)
      ]),
    );
  }
}