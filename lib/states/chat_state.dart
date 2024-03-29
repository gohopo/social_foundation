import 'package:collection/collection.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  List<TConversation> getList(String name) => list.where((data) => data.name==name).toList();
  int getListUnreadMessagesCount(List<TConversation> list) => list.fold(0, (previousValue, conv) => previousValue+conv.unreadMessagesCount);
  TConversation? getConversation(String convId) => list.firstWhereOrNull((data) => data.convId==convId);
  int getUnreadMessagesCount(String convId) => getConversation(convId)?.unreadMessagesCount??0;
  Future<TConversation?> queryConversation(String convId) async {
    return getConversation(convId);
  }
  void saveConversation(TConversation conversation,{bool? fromReceived,bool? unreadMessageCountUpdated}){
    var index = list.indexWhere((data) => data.convId==conversation.convId);
    if(index != -1){
      if(fromReceived == true){
        conversation.unreadMessagesCount = list[index].unreadMessagesCount;
      }
      else if(unreadMessageCountUpdated == true){
        conversation.unreadMessagesCount += list[index].unreadMessagesCount;
      }
      conversation = list[index]..copyWith(conversation);
      list.removeWhere((e) => e.convId==conversation.convId);
    }
    conversation.save();
    
    index = 0;
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
  void deleteConversation(TConversation conversation) async {
    await conversation.delete();
    list.removeWhere((e) => e.convId==conversation.convId);
    notifyListeners();
  }
  void read(String convId) async {
    var conv = await this.queryConversation(convId);
    if(conv==null) return;
    conv.unreadMessagesCount = 0;
    this.saveConversation(conv);
  }
  Future toggleTop(TConversation conversation) async {
    await conversation.toggleTop();
    saveConversation(conversation);
  }
}