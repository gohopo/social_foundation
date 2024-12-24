import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/locator_manager.dart';

abstract class SfConversation<TMessage extends SfMessage>{
  String ownerId;
  String convId;
  String name;
  String? creator;
  List members;
  int unreadMessagesCount;
  TMessage? lastMessage;
  int? lastMessageAt;
  int top;
  SfConversation(Map data)
  :ownerId=data['ownerId']??'',convId=data['convId']??'',name=data['name']??'chat',creator=data['creator'],members=data['members']??[]
  ,unreadMessagesCount=data['unreadMessagesCount']??0,lastMessage=data['lastMessage'],lastMessageAt=data['lastMessageAt'],top=data['top']??0;
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['convId'] = convId;
    map['name'] = name;
    map['creator'] = creator;
    map['members'] = json.encode(members);
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = lastMessage!=null ? json.encode(lastMessage?.toMap()) : null;
    map['lastMessageAt'] = lastMessageAt;
    map['top'] = top;
    return map;
  }
  void copyWith(SfConversation<TMessage> conversation){
    unreadMessagesCount = conversation.unreadMessagesCount;
    lastMessage = conversation.lastMessage;
    lastMessageAt = conversation.lastMessageAt;
  }
  String? get otherId => members.firstWhereOrNull((userId) => userId!=ownerId);
  Future save();
  static Future update(String ownerId,String convId,Map<String,dynamic> data) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.update('conversation',data,where:'ownerId=? and convId=?',whereArgs:[ownerId,convId]);
  }
  Future delete() async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    await database.delete('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
    SfLocatorManager.chatState.removeConversation(convId);
  }
  Future read() async {
    if(unreadMessagesCount==0) return;
    unreadMessagesCount = 0;
    await update(ownerId,convId,{'unreadMessagesCount':unreadMessagesCount});
    SfLocatorManager.chatState.updateConversation(this);
  }
  Future toggleTop() async {
    this.top = this.top==0 ? 1 : 0;
    await update(ownerId,convId,{'top':top});
    SfLocatorManager.chatState.updateConversation(this);
  }
  Future queryUnreadMessagesCount() async {
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'queryConversationUnreadCount', {
      'userId':ownerId,'convId':convId
    });
    unreadMessagesCount += result['count'] as int;
  }
}