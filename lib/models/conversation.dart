import 'dart:convert';

import 'package:social_foundation/models/message.dart';

abstract class SfConversation<TMessage extends SfMessage>{
  String ownerId;
  String convId;
  String creator;
  List<String> members;
  int unreadMessagesCount;
  TMessage lastMessage;
  int lastMessageAt;
  SfConversation(Map data) : ownerId = data['ownerId'],convId = data['convId'],creator = data['creator'],members = data['members'],unreadMessagesCount = data['unreadMessagesCount'],lastMessage = data['lastMessage'],lastMessageAt = data['lastMessageAt'];
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['convId'] = convId;
    map['creator'] = creator;
    map['members'] = json.encode(members);
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = json.encode(lastMessage.toMap());
    map['lastMessageAt'] = lastMessageAt;
    return map;
  }
  String get otherId => members.firstWhere((userId) => userId!=ownerId,orElse: ()=>null);
  Future<void> save();
}