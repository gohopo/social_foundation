import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/state/user_state.dart';
import '../config/storage_manager.dart';

import 'message.dart';

class Conversation extends ChatConversation<Message> {
  Conversation(Map<String,dynamic> data) : ownerId = data['ownerId'],super(data);
  String ownerId;

  static Conversation fromDB(Map<String,dynamic> data){
    data = Map.from(data);
    data['members'] = json.decode(data['members']).cast<String>();
    data['lastMessage'] = Message(json.decode(data['lastMessage']));
    return Conversation(data);
  }
  @override
  Map<String,dynamic> toMap(){
    var map = super.toMap();
    map['ownerId'] = ownerId;
    return map;
  }
  static Future<Conversation> query(String convId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=? and convId=?',whereArgs: [UserState.instance.curUser.userId,convId],limit: 1);
    return result.length>0 ? Conversation.fromDB(result[0]) : null;
  }
  static Future<List<Conversation>> queryAll(int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=?',whereArgs: [UserState.instance.curUser.userId],orderBy: 'lastMessageAt desc',limit: limit,offset: offset);
    return result.map(Conversation.fromDB).toList();
  }
  Future<int> insert() async {
    var database = await StorageManager.instance.getDatabase();
    return database.insert('conversation',toMap());
  }
  Future<int> update() async {
    var database = await StorageManager.instance.getDatabase();
    return database.update('conversation', {'lastMessage':lastMessage,'lastMessageAt':lastMessageAt},where: 'ownerId=? and convId=?',whereArgs: [UserState.instance.curUser.userId,convId]);
  }
  Future<int> save() async {
    var conversation = await query(convId);
    return conversation!=null ? update() : insert();
  }
}