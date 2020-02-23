import 'package:flutter/material.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/model/user.dart';
import 'package:social_foundation_example/widget/user_widget.dart';

class MessageItemWidget extends StatelessWidget{
  final Message message;
  final GestureTapCallback onTap;

  MessageItemWidget({
    this.message,
    this.onTap
  }) : super(key: ValueKey(message.msgId));
  Widget buildAvatar(User user){
    return Container(
      margin: EdgeInsets.only(right:5),
      child: UserAvatar(user: user)
    );
  }
  Widget buildNickName(User user){
    return Container(
      margin: EdgeInsets.only(bottom:5),
      child: UserNickName(user: user)
    );
  }
  Widget buildBubble(){
    return Text(message.msg);
  }

  @override
  Widget build(BuildContext context) {
    return UserConsumer(
      userId: message.fromId,
      builder: (context,user,child) => Container(
        padding: EdgeInsets.symmetric(horizontal:15,vertical: 10),
        child: Row(
          textDirection: message.fromOwner ? TextDirection.rtl : TextDirection.ltr,
          children: <Widget>[
            buildAvatar(user),
            Column(children: <Widget>[
              buildNickName(user),
              buildBubble()
            ],)
          ]
        ),
      ) 
    );
  }
}