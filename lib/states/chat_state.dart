import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/services/chat_manager.dart';
import 'package:social_foundation/widgets/view_state.dart';

abstract class SfChatState<TConversation extends SfConversation> extends SfRefreshListViewState<TConversation> {
  Future<TConversation> queryConversation(String convId) async {
    return list.firstWhere((data) => data.convId==convId,orElse: ()=>null);
  }
  void saveConversation(TConversation conversation,{bool fromReceived}){
    if(fromReceived == true){
      var index = list.indexWhere((data) => data.convId==conversation.convId);
      if(index != -1){
        conversation.unreadMessagesCount = list[index].unreadMessagesCount;
      }
    }
    conversation.save();
    list.removeWhere((e) => e.convId==conversation.convId);
    int index = 0;
    if(conversation.top == 0){
      for(;index<list.length;++index){
        var conv = list[index];
        if(conv.top!=0 || conv.lastMessageAt==null) continue;
        if(conversation.lastMessageAt==null || conv.lastMessageAt<=conversation.lastMessageAt){
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
    conv.unreadMessagesCount = 0;
    this.saveConversation(conv);
    GetIt.instance<SfChatManager>().convRead(convId);
  }
  Future toggleTop(TConversation conversation) async {
    await conversation.toggleTop();
    saveConversation(conversation);
  }
}