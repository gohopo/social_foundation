import 'dart:convert';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/service/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class Message extends ChatMessage {
  Message(Map data) : ownerId = data['ownerId'],id = data['id'],attribute = data['attribute'],super(data);
  String ownerId;
  int id;
  Map attribute;

  static Message fromDB(Map data){
    data = Map.from(data);
    if(data['attribute'] != null) data['attribute'] = json.decode(data['attribute']);
    return Message(data);
  }
  @override
  Map<String,dynamic> toMap(){
    var map = super.toMap();
    map['ownerId'] = ownerId;
    map['attribute'] = attribute!=null ? json.encode(attribute) : null;
    return map;
  }
  bool get fromOwner => fromId==ownerId;
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
  Future<Message> insert() async {
    var database = await StorageManager.instance.getDatabase();
    this.id = await database.insert('message',toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    return this;
  }
  Future<int> update() async {
    var database = await StorageManager.instance.getDatabase();
    return database.update('message', toMap(),where: 'id=?',whereArgs: [id]);
  }
}