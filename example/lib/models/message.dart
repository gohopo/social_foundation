import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class Message extends SfMessage {
  Message(Map data) : super(data);
  static Message fromDB(Map data){
    data = Map.from(data);
    if(data['attribute'] != null) data['attribute'] = json.decode(data['attribute']);
    if(data['msgExtra'] != null) data['msgExtra'] = json.decode(data['msgExtra']);
    return Message(data);
  }
  @override
  String get des{
    var des = super.des;
    if(status == SfMessageStatus.Sending) des = '[发送中...]  ' + des;
    return des;
  }
  static Future<Message> query(String id) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('message',where: 'id=?',whereArgs: [id],limit: 1);
    return result.length>0 ? Message.fromDB(result[0]) : null;
  }
  static Future<List<Message>> queryAll(String ownerId,String convId,int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('message',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId],orderBy: 'timestamp desc',limit: limit,offset: offset);
    return result.map(Message.fromDB).toList();
  }
  Future<void> save() async {
    var database = await StorageManager.instance.getDatabase();
    if(id != null){
      await database.update('message', toMap(),where: 'id=?',whereArgs: [id]);
    }
    else{
      this.id = await database.insert('message',toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
  static Future<void> insertAll(List<Message> messages) async {
    var database = await StorageManager.instance.getDatabase();
    var batch = database.batch();
    messages.forEach((message) => batch.insert('message',message.toMap(),conflictAlgorithm: ConflictAlgorithm.replace));
    var results = await batch.commit();
    for(var i=0;i<messages.length;++i){
      messages[i].id = results[i];
    }
  }
}