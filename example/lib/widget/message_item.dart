import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/model/message.dart';
import 'package:social_foundation_example/model/user.dart';
import 'package:social_foundation_example/service/chat_manager.dart';
import 'package:social_foundation_example/service/router_manager.dart';
import 'package:social_foundation_example/view_model/chat_model.dart';
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
  Widget buildContent(BuildContext context){
    Widget content;
    if(message.msgType == MessageType.text){
      content = buildText();
    }
    else if(message.msgType == MessageType.image){
      content = buildImage(context);
    }
    else if(message.msgType == MessageType.voice){
      content = buildVoice();
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
    return Row(children: <Widget>[
      Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: message.fromOwner ? Colors.grey[300] : Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(message.msg)
      ),

    ]);
  }
  Widget buildImage(BuildContext context){
    var chatModel = Provider.of<ChatModel>(context);
    return GestureDetector(
      onTap: (){
        var list = chatModel.list.where((data) => data.msgType==MessageType.image).toList().reversed.toList();
        var images = list.map((data) => FileImage(File(data.attribute['path']))).toList();
        var index = list.indexWhere((data) => data.id==message.id);
        Navigator.pushNamed(context, RouteName.PhotoViewer,arguments: {'images':images,'index':index});
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(
            File(message.attribute['path'])
          ),
        ),
      )
    );
  }
  Widget buildVoice(){
    return Row(
      children: <Widget>[

      ]
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
                buildContent(context)
              ]
            ),
            buildStatus()
          ]
        ),
      ) 
    );
  }
}