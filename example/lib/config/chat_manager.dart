import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/states/chat_state.dart';

class ChatManager extends ChatEventManager {
  saveConversation(ChatConversation conversation){
    GetIt.instance<ChatState>().saveConversation(conversation);
  }
  saveMessage(ChatMessage message){
    GetIt.instance<EventBus>().fire(message);
  }

  @override
  void onMessageReceived(ChatConversation conversation,ChatMessage message){
    saveConversation(conversation);
    saveMessage(message);
  }
  @override
  void onLastDeliveredAtUpdated(ChatConversation conversation, ChatMessage message) {
    // TODO: implement onLastDeliveredAtUpdated
  }
  @override
  void onLastReadAtUpdated(ChatConversation conversation, ChatMessage message) {
    // TODO: implement onLastReadAtUpdated
  }
  @override
  void onMessageRecalled(ChatConversation conversation, ChatMessage message) {
    // TODO: implement onMessageRecalled
  }
  @override
  void onMessageUpdated(ChatConversation conversation, ChatMessage message) {
    // TODO: implement onMessageUpdated
  }
  @override
  void onUnreadMessagesCountUpdated(ChatConversation conversation, ChatMessage message) {
    // TODO: implement onUnreadMessagesCountUpdated
  }
}