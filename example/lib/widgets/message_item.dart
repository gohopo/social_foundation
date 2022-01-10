import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/models/user.dart';
import 'package:social_foundation_example/services/chat_manager.dart';
import 'package:social_foundation_example/services/router_manager.dart';
import 'package:social_foundation_example/view_models/chat_model.dart';
import 'package:social_foundation_example/widgets/user_widget.dart';

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
      child: UserAvatar(user: user),
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
    if(message.msgType == SfMessageType.text){
      content = buildText();
    }
    else if(message.msgType == SfMessageType.image){
      content = buildImage(context);
    }
    else if(message.msgType == SfMessageType.voice){
      content = buildVoice();
    }
    return Container(
      child: content,
    );
  }
  Widget buildStatus(){
    Widget child;
    if(message.status == SfMessageStatus.sending){
      child = Text('发送中'); 
    }
    else if(message.status == SfMessageStatus.failed){
      child = Icon(Icons.error,color: Colors.red);
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal:7),
      child: child,
    );
  }
  Widget buildText(){
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: message.fromOwner ? Colors.grey[300] : Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(message.msg)
    );
  }
  Widget buildImage(BuildContext context){
    var chatModel = Provider.of<ChatModel>(context);
    return GestureDetector(
      onTap: (){
        var list = chatModel.list.where((data) => data.msgType==SfMessageType.image).toList().reversed.toList();
        var images = list.map((data) => data.resolveImage()).toList();
        var index = list.indexWhere((data) => data.id==message.id);
        Navigator.pushNamed(context, RouteName.PhotoViewer,arguments: {'images':images,'index':index});
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image(image: message.resolveImage()),
        ),
      )
    );
  }
  Widget buildVoice(){
    var read = message.fromOwner || (message.attribute['read'] ?? false);
    return SfBadge(
      visible: !read,
      width: 10,
      height: 10,
      top: 10,
      right: -20,
      child: SfAudioPlayerWidget(
        uri: message.resolveFileUri(),
        duration: message.msgExtra['duration'],
        width: 100,
        height: 30,
        color: Colors.grey[350],
        borderColor: Color(0xFFd9d9d9),
        onTap: (){
          if(!read){
            message.attribute['read'] = true;
            ChatManager.instance.saveMessage(message);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textDirection = message.fromOwner ? TextDirection.rtl : TextDirection.ltr;
    return UserConsumer(
      userId: message.fromId,
      builder: (context,user,child) => Container(
        padding: EdgeInsets.symmetric(horizontal:15,vertical: 10),
        child: Row(
          textDirection: textDirection,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildAvatar(user),
            Expanded(
              child: Column(
                crossAxisAlignment: message.fromOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  buildNickName(user),
                  Row(
                    textDirection: textDirection,
                    children: <Widget>[
                      Flexible(
                        child: buildContent(context),
                      ),
                      buildStatus()
                    ]
                  )
                ]
              ),
            )
          ]
        ),
      ) 
    );
  }
}