import 'package:collection/collection.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  List<TConversation> getList(String name) => list.where((data) => data.name==name).toList();
  int getListUnreadMessagesCount(List<TConversation> list) => list.fold(0, (previousValue, conv) => previousValue+conv.unreadMessagesCount);
  TConversation? getConversation(String convId) => list.firstWhereOrNull((data) => data.convId==convId);
  int getUnreadMessagesCount(String convId) => getConversation(convId)?.unreadMessagesCount??0;
  void updateConversation(TConversation conversation){
    list.removeWhere((x) => x.convId==conversation.convId);
    var index = 0;
    if(conversation.top == 0){
      for(;index<list.length;++index){
        var conv = list[index];
        if(conv.top!=0 || conv.lastMessageAt==null) continue;
        if(conversation.lastMessageAt==null || conv.lastMessageAt!<=conversation.lastMessageAt!){
          break;
        }
      }
    }
    list.insert(index,conversation);
    notifyListeners();
  }
  void removeConversation(String convId){
    list.removeWhere((x) => x.convId==convId);
    notifyListeners();
  }
  Future<TConversation?> queryConversation(String convId) async {
    return getConversation(convId);
  }
}