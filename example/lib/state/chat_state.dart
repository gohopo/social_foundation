import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../model/conversation.dart';

class ChatState with ChangeNotifier{
  static ChatState get instance => GetIt.instance<ChatState>();
  List<Conversation> conversations = [];

  void loadMore() async {
    var result = await Conversation.queryAll(20, conversations.length);
    conversations.addAll(result);
    notifyListeners();
  }
  void saveConversation(Conversation conversation){
    conversations.removeWhere((e) => e.convId==conversation.convId);
    conversations.insert(0,conversation);
    notifyListeners();
  }
}