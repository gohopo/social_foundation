import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/model/user.dart';
import 'package:social_foundation_example/service/chat_manager.dart';
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
      margin: EdgeInsets.symmetric(horizontal:5),
      child: UserAvatar(user: user)
    );
  }
  Widget buildNickName(User user){
    return Container(
      margin: EdgeInsets.only(bottom:5),
      child: UserNickName(user: user)
    );
  }
  Widget buildContent(){
    Widget content;
    if(message.msgType == MessageType.text){
      content = buildText();
    }
    else if(message.msgType == MessageType.image){
      content = buildImage();
    }
    return Container(
      child: content,
    );
  }
  Widget buildStatus(){
    Widget child;
    if(message.status == ChatMessageStatus.Sending){
      child = Text('发送中'); 
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal:5),
      child: child,
    );
  }
  Widget buildText(){
    return Text(message.msg);
  }
  Widget buildImage(){
    return Image.file(
      File(message.attribute['path']),
      width: 120,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserConsumer(
      userId: message.fromId,
      builder: (context,user,child) => Container(
        padding: EdgeInsets.symmetric(horizontal:15,vertical: 10),
        child: Row(
          textDirection: message.fromOwner ? TextDirection.rtl : TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildAvatar(user),
            Column(
              crossAxisAlignment: message.fromOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                buildNickName(user),
                buildContent()
              ]
            ),
            buildStatus()
          ]
        ),
      ) 
    );
  }
}