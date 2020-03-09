import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  Future<TConversation> queryConversation(String convId) async {
    return list.firstWhere((data) => data.convId==convId,orElse: ()=>null);
  }
  void saveConversation(TConversation conversation){
    conversation.save();
    list.removeWhere((e) => e.convId==conversation.convId);
    list.insert(0,conversation);
    notifyListeners();
  }
}