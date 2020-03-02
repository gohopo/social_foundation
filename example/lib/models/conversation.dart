import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/message.dart';
import 'package:social_foundation_example/services/storage_manager.dart';

class Conversation extends SfConversation<Message> {
  Conversation(Map data) : ownerId = data['ownerId'],super(data);
  String ownerId;

  static Conversation fromDB(Map data){
    data = Map.from(data);
    data['members'] = json.decode(data['members']).cast<String>();
    data['lastMessage'] = Message.fromDB(json.decode(data['lastMessage']));
    return Conversation(data);
  }
  @override
  Map<String,dynamic> toMap(){
    var map = super.toMap();
    map['ownerId'] = ownerId;
    return map;
  }
  String get otherId => members.firstWhere((userId) => userId!=ownerId,orElse: ()=>null);
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
  Future<int> insert() async {
    var database = await StorageManager.instance.getDatabase();
    return database.insert('conversation',toMap());
  }
  Future<int> update() async {
    var database = await StorageManager.instance.getDatabase();
    return database.update('conversation', {'lastMessage':json.encode(lastMessage.toMap()),'lastMessageAt':lastMessageAt},where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
  }
  Future<int> save() async {
    var conversation = await query(ownerId,convId);
    return conversation!=null ? update() : insert();
  }
}