import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/states/chat_state.dart';
import 'package:social_foundation_example/view_models/message_model.dart';
import 'package:social_foundation_example/widgets/conversation_item.dart';

class MessagePage extends StatelessWidget {

  Widget buildList(BuildContext context,ChatState model1,MessageModel model2){
    return SmartRefresher(
      controller: model1.refreshController,
      onRefresh: model1.refresh,
      onLoading: model1.loadMore,
      enablePullDown: false,
      enablePullUp: true,
      child: ListView.builder(
        itemCount: model1.list.length,
        itemBuilder: (context,index){
          var conv = model1.list[index];
          return ConversationItemWidget(conversation: conv);
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var model1 = Provider.of<ChatState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('消息')),
      body: SfProvider<MessageModel>(
        model: MessageModel(),
        builder: (context,model2,child) => buildList(context,model1,model2),
      )
    );
  }
}