import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/state/user_state.dart';
import '../model/message.dart';
import '../model/conversation.dart';
import '../state/chat_state.dart';

class ChatManager extends ChatEventManager<Conversation,Message> {
  static ChatManager get instance => GetIt.instance<ChatManager>();
  ChatManager(String appId, String appKey, String serverURL) : super(appId,appKey,serverURL);
  saveConversation(Conversation conversation){
    conversation.save();
    ChatState.instance.saveConversation(conversation);
  }
  saveMessage(Message message){
    message.insert();
    GetIt.instance<EventBus>().fire(message);
  }

  @override
  Conversation convertConversation(Map<String,dynamic> data) {
    data['ownerId'] = UserState.instance.curUser.userId;
    return Conversation(data);
  }
  @override
  Message convertMessage(Map<String,dynamic> data) {
    data['ownerId'] = UserState.instance.curUser.userId;
    return Message(data);
  }
  @override
  void onMessageReceived(Conversation conversation,Message message){
    saveConversation(conversation);
    saveMessage(message);
  }
  @override
  void onLastDeliveredAtUpdated(Conversation conversation, Message message) {

  }
  @override
  void onLastReadAtUpdated(Conversation conversation, Message message) {
  
  }
  @override
  void onMessageRecalled(Conversation conversation, Message message) {
  
  }
  @override
  void onMessageUpdated(Conversation conversation, Message message) {

  }
  @override
  void onUnreadMessagesCountUpdated(Conversation conversation, Message message) {

  }
}