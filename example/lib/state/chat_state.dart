import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/conversation.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:social_foundation_example/state/view_state.dart';

class ChatState extends RefreshListViewState<Conversation> {
  static ChatState get instance => GetIt.instance<ChatState>();

  void saveConversation(Conversation conversation){
    conversation.save();
    list.removeWhere((e) => e.convId==conversation.convId);
    list.insert(0,conversation);
    notifyListeners();
  }

  @override
  Future<List<Conversation>> loadData(bool refresh) {
    return Conversation.queryAll(UserState.instance.curUserId,20, refresh ? 0 : list.length);
  }
}