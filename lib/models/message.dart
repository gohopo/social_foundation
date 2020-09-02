import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';
import 'package:sqflite/sqflite.dart';

class SfMessage {
  int id;
  String ownerId;
  String msgId;
  String convId;
  String fromId;
  int timestamp;
  int status;
  int receiptTimestamp;
  Map attribute;
  String msg;
  String msgType;
  Map msgExtra;
  SfMessage(Map data)
    :id = data['id'],ownerId = data['ownerId'],msgId = data['msgId'],convId = data['convId'],fromId = data['fromId'],timestamp = data['timestamp']
    ,status = data['status'],receiptTimestamp = data['receiptTimestamp'],attribute = data['attribute']??{}
    ,msg = data['msg'],msgType = data['msgType'],msgExtra = data['msgExtra']??{};
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['msgId'] = msgId;
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['timestamp'] = timestamp;
    map['status'] = status;
    map['receiptTimestamp'] = receiptTimestamp;
    map['attribute'] = json.encode(attribute);
    map['msg'] = msg;
    map['msgType'] = msgType;
    map['msgExtra'] = json.encode(msgExtra);
    return map;
  }
  bool get fromOwner => fromId==ownerId;
  bool get transient => attribute['transient']??false;
  String get origin => json.encode({
    'msg': msg,
    'msgType': msgType,
    'msgExtra': msgExtra
  });
  String get des{
    switch(msgType){
      case SfMessageType.text:
        return msg;
      case SfMessageType.image:
        return '[图片]';
      case SfMessageType.voice:
        return '[声音]';
      default:
        return '';
    }
  }
  String resolveFileUri() => msgExtra['fileKey']!=null ? SfAliyunOss.getFileUrl(msgType,msgExtra['fileKey']) : (attribute['filePath'] ?? '');
  ImageProvider resolveImage() => msgExtra['fileKey']!=null ? SfCacheManager.provder(SfAliyunOss.getImageUrl(msgExtra['fileKey'])) :(attribute['filePath']!=null ? FileImage(File(attribute['filePath'])) : null);
  Future save() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    if(id != null){
      await database.update('message', toMap(),where: 'id=?',whereArgs: [id]);
    }
    else{
      this.id = await database.insert('message',toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
  static Future insertAll<TMessage extends SfMessage>(List<TMessage> messages) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    var batch = database.batch();
    messages.forEach((message) => batch.insert('message',message.toMap(),conflictAlgorithm: ConflictAlgorithm.replace));
    var results = await batch.commit();
    for(var i=0;i<messages.length;++i){
      messages[i].id = results[i];
    }
  }
  static Future<int> sumMessageCount(String userId) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    return Sqflite.firstIntValue(await database.rawQuery('select count(*) from message where fromId="$userId"'));
  }
  static Future delete(int id) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    return database.delete('message',where:'id=?',whereArgs:[id]);
  }
}

class SfMessageStatus{
  static const int failed = 0;//失败
  static const int none = 1;//未知
  static const int sending = 2;//发送中
  static const int sent = 3;//发送成功
  static const int delivered = 4;//被接收
  static const int read = 5;//已读
}

class SfMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
  static const String system = 'system';
  static const String notify = 'notify';
  static const String recall = 'recall';
}