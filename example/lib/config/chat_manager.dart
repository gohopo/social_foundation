import 'package:social_foundation/social_foundation.dart';

class ChatManager extends ChatEventHandler{
  void onMessageReceived(ChatConversation conversation,ChatMessage message){
    print(message);
  }
}