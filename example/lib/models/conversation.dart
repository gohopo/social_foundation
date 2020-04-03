import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/services/storage_manager.dart';

class Conversation extends SfConversation<Message> {
  Conversation(Map data) : super(data);
  static fromDB(Map data){
    data = Map.from(data);
    data['members'] = json.decode(data['members']).cast<String>();
    data['lastMessage'] = data['lastMessage']!=null ? Message.fromDB(json.decode(data['lastMessage'])) : null;
  }
  @override
  Future<void> save() async {
    var conversation = await query(ownerId,convId);
    var database = await StorageManager.instance.getDatabase();
    if(conversation != null){
      var map = toMap();
      await database.update('conversation', {'lastMessage':map['lastMessage'],'lastMessageAt':map['lastMessageAt']}, where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
    }
    else{
      await database.insert('conversation',toMap());
    }
  }
  static Future<Conversation> query(String ownerId,String convId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId],limit: 1);
    return result.length>0 ? Conversation.fromDB(result[0]) : null;
  }
  static Future<List<Conversation>> queryAll(String ownerId,int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('conversation',where: 'ownerId=?',whereArgs: [ownerId],orderBy: 'top desc,lastMessageAt desc',limit: limit,offset: offset);
    return result.map(Conversation.fromDB).toList();
  }
}