import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/state/chat_state.dart';

class ChatManager extends ChatEventManager<ChatConversation,ChatMessage> {
  ChatManager(String appId, String appKey, String serverURL) : super(appId,appKey,serverURL);
  saveConversation(ChatConversation conversation){
    GetIt.instance<ChatState>().saveConversation(conversation);
  }
  saveMessage(ChatMessage message){
    GetIt.instance<EventBus>().fire(message);
  }

  @override
  ChatConversation convertConversation(String conversation) {
    return conversation == null ? null : ChatConversation.fromJsonString(conversation);
  }
  @override
  ChatMessage convertMessage(String message) {
    return message == null ? null : ChatMessage.fromJsonString(message);
  }
  @override
  void onMessageReceived(ChatConversation conversation,ChatMessage message){
    saveConversation(conversation);
    saveMessage(message);
  }
  @override
  void onLastDeliveredAtUpdated(ChatConversation conversation, ChatMessage message) {

  }
  @override
  void onLastReadAtUpdated(ChatConversation conversation, ChatMessage message) {
  
  }
  @override
  void onMessageRecalled(ChatConversation conversation, ChatMessage message) {
  
  }
  @override
  void onMessageUpdated(ChatConversation conversation, ChatMessage message) {

  }
  @override
  void onUnreadMessagesCountUpdated(ChatConversation conversation, ChatMessage message) {

  }
}