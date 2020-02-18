import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';

class ChatState with ChangeNotifier{
  List<ChatConversation> conversations = [];

  void saveConversation(ChatConversation conversation){
    conversations.removeWhere((e) => e.convId==conversation.convId);
    conversations.add(conversation);
    notifyListeners();
  }
}