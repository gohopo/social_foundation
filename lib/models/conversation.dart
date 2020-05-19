import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/storage_manager.dart';

abstract class SfConversation<TMessage extends SfMessage>{
  String ownerId;
  String convId;
  String creator;
  List members;
  int unreadMessagesCount;
  TMessage lastMessage;
  int lastMessageAt;
  int top;
  SfConversation(Map data) : ownerId = data['ownerId'],convId = data['convId'],creator = data['creator'],members = data['members'],unreadMessagesCount = data['unreadMessagesCount']??0,lastMessage = data['lastMessage'],lastMessageAt = data['lastMessageAt'],top=data['top']??0;
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['convId'] = convId;
    map['creator'] = creator;
    map['members'] = json.encode(members);
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = lastMessage!=null ? json.encode(lastMessage.toMap()) : null;
    map['lastMessageAt'] = lastMessageAt;
    map['top'] = top;
    return map;
  }
  String get otherId => members.firstWhere((userId) => userId!=ownerId,orElse: ()=>null);
  Future save();
  Future delete() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    await database.delete('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
  }
  Future toggleTop() async {
    int top = this.top==0 ? 1 : 0;
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    await database.update('conversation', {'top':top}, where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
  }
}