import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import '../config/storage_manager.dart';
import '../state/app_state.dart';

import 'message.dart';

class Conversation extends ChatConversation<Message> {
  Conversation(Map<String,dynamic> data) : ownerId = data['ownerId'],super(data);
  String ownerId;
  static Conversation fromDB(Map<String,dynamic> data){
    data['members'] = json.decode(data['members']).cast<String>();
    data['lastMessage'] = Message(json.decode(data['lastMessage']));
    return Conversation(data);
  }
  static Future<Conversation> query(String convId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId="?" and convId="?"',whereArgs: [AppState.instance.curUser.userId,convId],limit: 1);
    return result.length>0 ? Conversation.fromDB(result[0]) : null;
  }
  static Future<List<Conversation>> queryAll(String orderBy,int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId="?"',whereArgs: [AppState.instance.curUser.userId],orderBy: orderBy,limit: limit,offset: offset);
    return result.map(Conversation.fromDB);
  }
  Future<int> insert() async {
    var database = await StorageManager.instance.getDatabase();
    return database.insert('conversation',toMap());
  }
  Future<int> update() async {
    var database = await StorageManager.instance.getDatabase();
    return database.update('conversation', {'lastMessage':lastMessage,'lastMessageAt':lastMessageAt},where: 'ownerId="?" and convId="?"',whereArgs: [AppState.instance.curUser.userId,convId]);
  }
  Future<int> save() async {
    var conversation = await query(convId);
    return conversation!=null ? update() : insert();
  }
}