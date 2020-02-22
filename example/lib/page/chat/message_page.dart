import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_foundation_example/state/chat_state.dart';
import 'package:social_foundation_example/view_model/message_model.dart';
import 'package:social_foundation_example/widget/conversation_item.dart';
import 'package:social_foundation_example/widget/provider_widget.dart';

class MessagePage extends StatelessWidget {

  Widget buildList(BuildContext context,ChatState model1,MessageModel model2){
    return SmartRefresher(
      controller: model1.refreshController,
      onRefresh: model1.refresh,
      onLoading: model1.loadMore,
      enablePullUp: true,
      child: ListView.separated(
        itemCount: model1.list.length,
        itemBuilder: (context,index){
          var conv = model1.list[index];
          return ConversationItemWidget(conversation: conv);
        },
        separatorBuilder: (context,index) => Divider(color: Colors.green)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('消息')),
      body: ProviderWidget2<ChatState,MessageModel>(
        model1: ChatState.instance,
        model2: MessageModel(),
        onModelReady: (model1,model2) => model1.initData(),
        builder: (context,model1,model2,child) => buildList(context,model1,model2),
      )
    );
  }
}