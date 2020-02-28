import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/service/chat_manager.dart';
import 'package:social_foundation_example/state/user_state.dart';

class ChatState extends RefreshListViewState<Conversation> {
  static ChatState get instance => GetIt.instance<ChatState>();

  Future<Conversation> queryConversation(String convId) async {
    var conversation = list.firstWhere((data) => data.convId==convId,orElse: ()=>null);
    return conversation ?? Conversation.query(UserState.instance.curUserId, convId);
  }
  void saveConversation(Conversation conversation){
    conversation.save();
    list.removeWhere((e) => e.convId==conversation.convId);
    list.insert(0,conversation);
    notifyListeners();
  }
  void convRead(Conversation conversation) async {
    await ChatManager.instance.convRead(conversation.convId);
    conversation.unreadMessagesCount = 0;
    saveConversation(conversation);
  }

  @override
  Future<List<Conversation>> loadData(bool refresh) {
    return Conversation.queryAll(UserState.instance.curUserId,20, refresh ? 0 : list.length);
  }
}