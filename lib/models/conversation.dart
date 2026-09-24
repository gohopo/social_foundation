import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:social_foundation/models/entity.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/locator_manager.dart';

abstract class SfConversation<TMessage extends SfMessage> extends SfEntity{
  late String convId;
  String? creator;
  late Map dict;
  TMessage? lastMessage;
  late int lastMessageAt;
  late List members;
  late String name;
  late String ownerId;
  late int top;
  late int unreadMessagesCount;
  SfConversation(super.data);
  @override
  void populate(Map data){
    convId = data['convId']??'';
    creator = data['creator'];
    dict = <dynamic,dynamic>{...data['dict']??{}};
    lastMessage = data['lastMessage'];
    lastMessageAt = data['lastMessageAt']??DateTime.now().millisecondsSinceEpoch;
    members = data['members']??[];
    name = data['name']??'chat';
    ownerId = data['ownerId']??SfLocatorManager.userState.curUserId;
    top = data['top']??0;
    unreadMessagesCount = data['unreadMessagesCount']??0;
  }
  @override
  void populateDB(Map data){
    super.populateDB({
      ...data,
      'dict': jsonDecode(data['dict']??'{}'),
      'members': json.decode(data['members']??'[]').cast<String>()
    });
  }
  @override
  Map<String,dynamic> toDB(){
    var map = toJson();
    map['dict'] = jsonEncode(dict);
    if(lastMessage!=null) map['lastMessage'] = json.encode(lastMessage!.toDB());
    map['members'] = json.encode(members);
    return map;
  }
  @override
  Map<String,dynamic> toJson() => {
    'convId': convId,
    'creator': creator,
    'dict': dict,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt,
    'members': members,
    'name': name,
    'ownerId': ownerId,
    'top': top,
    'unreadMessagesCount': unreadMessagesCount
  };
  String? get otherId => type==0 ? members.firstWhereOrNull((userId) => userId!=ownerId) : null;
  /// 会话类型
  ///
  /// 0: 单聊
  /// 1: 群聊
  /// 2: 聊天室
  int get type => dict['__type']??0;
  void copyWith(SfConversation<TMessage> conversation){
    unreadMessagesCount = conversation.unreadMessagesCount;
    lastMessage = conversation.lastMessage;
    lastMessageAt = conversation.lastMessageAt;
  }
  Future delete() async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    await database.delete('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
    SfLocatorManager.chatState.removeConversation(convId);
  }
  static Future deleteAll(String ownerId) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    await database.delete('conversation',where: 'ownerId=?',whereArgs: [ownerId]);
    SfLocatorManager.chatState.removeAllConversations();
  }
  @override
  bool equals(covariant SfConversation other) => convId==other.convId || super.equals(other);
  Future queryUnreadMessagesCount() async {
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'queryConversationUnreadCount', {
      'userId':ownerId,'convId':convId
    });
    unreadMessagesCount += result['count'] as int;
  }
  Future read() async {
    if(unreadMessagesCount==0) return;
    unreadMessagesCount = 0;
    await update(ownerId,convId,{'unreadMessagesCount':unreadMessagesCount});
    SfLocatorManager.chatState.updateConversation(this);
  }
  Future save();
  Future toggleTop() async {
    this.top = this.top==0 ? 1 : 0;
    await update(ownerId,convId,{'top':top});
    SfLocatorManager.chatState.updateConversation(this);
  }
  static Future update(String ownerId,String convId,Map<String,dynamic> data) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.update('conversation',data,where:'ownerId=? and convId=?',whereArgs:[ownerId,convId]);
  }
}