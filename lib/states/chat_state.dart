import 'package:collection/collection.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  TConversation? getConversation(String convId) => list.firstWhereOrNull((data) => data.convId==convId);
  List<TConversation> getList(String name) => list.where((data) => data.name==name).toList();
  List<TConversation> getListByNames(List<String> names) => list.where((data) => names.contains(data.name)).toList();
  int getListUnreadMessagesCount(List<TConversation> list) => list.fold(0, (previousValue, conv) => previousValue+conv.unreadMessagesCount);
  int getUnreadMessagesCount(String convId) => getConversation(convId)?.unreadMessagesCount??0;
  Future<TConversation?> queryConversation(String convId) async {
    return getConversation(convId);
  }
  void removeAllConversations(){
    list.clear();
    notifyListeners();
  }
  void removeConversation(String convId){
    list.removeWhere((x) => x.convId==convId);
    notifyListeners();
  }
  void updateConversation(TConversation conversation){
    list.removeWhere((x) => x.convId==conversation.convId);
    var index = 0;
    if(conversation.top == 0){
      for(;index<list.length;++index){
        var conv = list[index];
        if(conv.top!=0) continue;
        if(conv.lastMessageAt<=conversation.lastMessageAt){
          break;
        }
      }
    }
    list.insert(index,conversation);
    notifyListeners();
  }
 }