import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  Future<TConversation> queryConversation(String convId) async {
    return list.firstWhere((data) => data.convId==convId,orElse: ()=>null);
  }
  void saveConversation(TConversation conversation){
    conversation.save();
    list.removeWhere((e) => e.convId==conversation.convId);
    int index = 0;
    if(conversation.top == 0){
      for(;index<list.length;++index){
        var conv = list[index];
        if(conv.top!=0 || conv.lastMessageAt==null) continue;
        if(conversation.lastMessageAt==null || conv.lastMessageAt>=conversation.lastMessageAt){
          break;
        }
      }
    }
    list.insert(index,conversation);
    notifyListeners();
  }
  void deleteConversation(TConversation conversation) async {
    await conversation.delete();
    list.removeWhere((e) => e.convId==conversation.convId);
    notifyListeners();
  }
  Future toggleTop(TConversation conversation) async {
    await conversation.toggleTop();
    saveConversation(conversation);
  }
}