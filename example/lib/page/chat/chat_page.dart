import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/view_model/chat_model.dart';
import 'package:social_foundation_example/widget/chat_input.dart';
import 'package:social_foundation_example/widget/message_item.dart';
import 'package:social_foundation_example/widget/provider_widget.dart';

class ChatPage extends StatelessWidget {
  final Conversation conversation;

  ChatPage({@required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天')),
      body: ProviderWidget<ChatModel>(
        model: ChatModel(conversation: conversation),
        onModelReady: (model) => model.initData(),
        builder: (context,model,child) => Column(
          children: <Widget>[
            Expanded(
              child: buildMessages(context,model)
            ),
            buildInput()
          ]
        ),
      )
    );
  }
  Widget buildMessages(BuildContext context,ChatModel model){
    return SmartRefresher(
      controller: model.refreshController,
      onRefresh: model.refresh,
      onLoading: model.loadMore,
      enablePullUp: true,
      child: ListView.builder(
        itemCount: model.list.length,
        itemBuilder: (context,index) => MessageItemWidget(message: model.list[index])
      ),
    );
  }
  Widget buildInput(){
    return ChatInput();
  }
}