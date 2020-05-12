import 'dart:math';

import 'package:social_foundation/view_models/chat_model.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../states/user_state.dart';

class ChatModel extends SfChatModel<Conversation,Message>{
  ChatModel(Map args) : super(args);

  @override
  Future<List<Message>> loadData(bool refresh) {
    return Message.queryAll(UserState.instance.curUserId,conversation.convId, max(conversation.unreadMessagesCount, 20), refresh ? 0 : list.length);
  }
}