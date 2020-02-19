import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../model/conversation.dart';

class ChatState with ChangeNotifier{
  static ChatState get instance => GetIt.instance<ChatState>();
  List<Conversation> conversations = [];

  void saveConversation(Conversation conversation){
    conversations.removeWhere((e) => e.convId==conversation.convId);
    conversations.add(conversation);
    notifyListeners();
  }
}