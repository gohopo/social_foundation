import 'package:social_foundation/states/chat_state.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/states/user_state.dart';

class ChatState extends SfChatState<Conversation>{
  @override
  Future<Conversation> queryConversation(String convId) async {
    var conversation = super.queryConversation(convId);
    return conversation ?? Conversation.query(UserState.instance.curUserId, convId);
  }
  @override
  Future<List<Conversation>> loadData(bool refresh) {
    return Conversation.queryAll(UserState.instance.curUserId,20, refresh ? 0 : list.length);
  }
}