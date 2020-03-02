import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/view_models/chat_model.dart';
import 'package:social_foundation_example/widgets/chat_input.dart';
import 'package:social_foundation_example/widgets/message_item.dart';

class ChatPage extends StatelessWidget {
  final Conversation conversation;

  ChatPage({@required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天')),
      body: SfProviderWidget<ChatModel>(
        model: ChatModel(conversation: conversation),
        onModelReady: (model) => model.initData(),
        builder: (context,model,child) => Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => model.inputModel.changeAccessory(-2),
                child: buildMessages(context,model),
              )
            ),
            buildInput(context,model)
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
      reverse: true,
      enablePullDown: false,
      enablePullUp: true,
      child: ListView.builder(
        controller: model.scrollController,
        itemCount: model.list.length,
        itemBuilder: (context,index) => MessageItemWidget(message: model.list[index])
      ),
    );
  }
  Widget buildInput(BuildContext context,ChatModel model){
    return ChatInput(
      model: model.inputModel,
    );
  }
}