import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class Conversation extends SfConversation<Message> {
  Conversation(Map data) : super(data);
  static Conversation fromDB(Map data){
    data = Map.from(data);
    data['members'] = json.decode(data['members']).cast<String>();
    data['lastMessage'] = Message.fromDB(json.decode(data['lastMessage']));
    return Conversation(data);
  }
  static Future<Conversation> query(String ownerId,String convId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId],limit: 1);
    return result.length>0 ? Conversation.fromDB(result[0]) : null;
  }
  static Future<List<Conversation>> queryAll(String ownerId,int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=?',whereArgs: [ownerId],orderBy: 'lastMessageAt desc',limit: limit,offset: offset);
    return result.map(Conversation.fromDB).toList();
  }
  Future<void> save() async {
    var database = await StorageManager.instance.getDatabase();
    if(id != null){
      await database.update('conversation', {'unreadMessagesCount':unreadMessagesCount,'lastMessage':json.encode(lastMessage.toMap()),'lastMessageAt':lastMessageAt},where: 'id=?',whereArgs: [id]);
    }
    else{
      this.id = await database.insert('conversation',toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}