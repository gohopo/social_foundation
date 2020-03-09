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
  String status;
  int receiptTimestamp;
  Map attribute;
  String msg;
  String msgType;
  Map msgExtra;
  SfMessage(Map data) : id = data['id'],ownerId = data['ownerId'],msgId = data['msgId'],convId = data['convId'],fromId = data['fromId'],timestamp = data['timestamp'],status = data['status'],receiptTimestamp = data['receiptTimestamp'],attribute = data['attribute']??{},msg = data['msg'],msgType = data['msgType'],msgExtra = data['msgExtra']??{};
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['attribute'] = json.encode(attribute);
    map['msgId'] = msgId;
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['timestamp'] = timestamp;
    map['status'] = status;
    map['receiptTimestamp'] = receiptTimestamp;
    map['msg'] = msg;
    map['msgType'] = msgType;
    map['msgExtra'] = json.encode(msgExtra);
    return map;
  }
  bool get fromOwner => fromId==ownerId;
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
  ImageProvider resolveImage() => msgExtra['fileKey']!=null ? SfCachedImageProvider(SfAliyunOss.getImageUrl(msgExtra['fileKey'])) :(attribute['filePath']!=null ? FileImage(File(attribute['filePath'])) : null);
  Future<void> save() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    if(id != null){
      await database.update('message', toMap(),where: 'id=?',whereArgs: [id]);
    }
    else{
      this.id = await database.insert('message',toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
  static Future<void> insertAll<TMessage extends SfMessage>(List<TMessage> messages) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    var batch = database.batch();
    messages.forEach((message) => batch.insert('message',message.toMap(),conflictAlgorithm: ConflictAlgorithm.replace));
    var results = await batch.commit();
    for(var i=0;i<messages.length;++i){
      messages[i].id = results[i];
    }
  }
}

class SfMessageStatus {
  static const String None = 'AVIMMessageStatusNone'; //未知
  static const String Sending = 'AVIMMessageStatusSending'; //发送中
  static const String Sent = 'AVIMMessageStatusSent'; //发送成功
  static const String Receipt = 'AVIMMessageStatusReceipt'; //被接收
  static const String Failed = 'AVIMMessageStatusFailed'; //失败
}

class SfMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
}