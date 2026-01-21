import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/entity.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/utils/aliyun_helper.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';
import 'package:sqflite/sqflite.dart';

class SfMessage {
  Map attribute;
  String convId;
  String fromId;
  int? id;
  String? msg;
  Map msgExtra;
  String? msgId;
  String msgType;
  String ownerId;
  int? receiptTimestamp;
  int status;
  int timestamp;
  SfMessage(Map data)
  :attribute=data['attribute']??{},convId=data['convId']??'',fromId=data['fromId']??'',id=data['id'],msg=data['msg'],msgExtra=data['msgExtra']??{},msgId=data['msgId'],msgType=data['msgType']??SfMessageType.text
  ,ownerId=data['ownerId']??SfLocatorManager.userState.curUserId??'',receiptTimestamp=data['receiptTimestamp'],status=data['status']??SfMessageStatus.none,timestamp=data['timestamp']??0;
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['attribute'] = json.encode(attribute);
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['msg'] = msg;
    map['msgExtra'] = json.encode(msgExtra);
    map['msgId'] = msgId;
    map['msgType'] = msgType;
    map['ownerId'] = ownerId;
    map['receiptTimestamp'] = receiptTimestamp;
    map['status'] = status;
    map['timestamp'] = timestamp;
    return map;
  }
  String get des{
    switch(msgType){
      case SfMessageType.text:
        return msg??'';
      case SfMessageType.image:
        return '[图片]';
      case SfMessageType.voice:
        return '[声音]';
      case SfMessageType.system:
        return '[系统]';
      case SfMessageType.notify:
        return '[通知]';
      case SfMessageType.recall:
        return '[已撤回]';
      default:
        return '';
    }
  }
  bool get fromOwner => fromId==ownerId;
  String get origin => json.encode({
    'msg': msg,
    'msgType': msgType,
    'msgExtra': msgExtra
  });
  bool get transient => msgExtra['transient']??false;
  static Future delete(int id) => SfSyncEntity.delete('message',where:'id=?',whereArgs:[id]);
  static Future deleteAll(String ownerId,String convId) async {
    var result = await SfSyncEntity.delete('message',where:'ownerId=? and convId=?',whereArgs:[ownerId,convId]);
    SfMessageClearEvent(convId:convId).emit();
    return result;
  }
  bool equalTo(SfMessage other) => msgId!=null&&msgId==other.msgId || id!=null&&id==other.id || this==other;
  String resolveFileUri() => msgExtra['fileKey']!=null ? SfAliyunOss.getFileUrl(msgType,msgExtra['fileKey']) : (attribute['filePath'] ?? '');
  ImageProvider? resolveImage() => msgExtra['fileKey']!=null ? SfCacheManager.provider(SfAliyunOss.getImageUrl(msgExtra['fileKey'])) as ImageProvider : (attribute['filePath']!=null ? FileImage(File(attribute['filePath'])) : null);
  Future save() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    if(id!=null){
      await database.update('message',toMap(),where:'id=?',whereArgs:[id]);
    }
    else if(msgType==SfMessageType.recall){
      await database.update('message',toMap(),where:'msgId=?',whereArgs:[msgId]);
    }
    else{
      this.id = await database.insert('message',toMap(),conflictAlgorithm:ConflictAlgorithm.replace);
    }
  }
  static Future saveAll<TMessage extends SfMessage>(List<TMessage> messages) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    var batch = database.batch();
    for(var message in messages){
      if(message.id!=null){
        batch.update('message',message.toMap(),where:'id=?',whereArgs:[message.id]);
      }
      else if(message.msgType==SfMessageType.recall){
        batch.update('message',message.toMap(),where:'msgId=?',whereArgs:[message.msgId]);
      }
      else{
        batch.insert('message',message.toMap(),conflictAlgorithm:ConflictAlgorithm.replace);
      }
    }
    var results = await batch.commit();
    for(var i=0;i<messages.length;++i){
      messages[i].id ??= results[i] as int;
    }
  }
  static Future<int> sumMessageCount(String ownerId,String convId,String userId,{int? startTime,int? endTime,bool? real}) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    var where = 'ownerId="$ownerId" and convId="$convId" and fromId="$userId" and msgType!="${SfMessageType.system}"';
    if(startTime!=null) where += ' and timestamp>=$startTime';
    if(endTime!=null) where += ' and timestamp<=$endTime';
    if(real==true) where += ' and msgId is not null';
    return Sqflite.firstIntValue(await database.rawQuery('select count(*) from message where $where'))!;
  }
  static Future update({int? id,String? msgId,required Map<String,dynamic> data}) async {
    List<String> where=[];List<Object?> whereArgs=[];
    if(id!=null){
      where.add('id=?');
      whereArgs.add(id);
    }
    if(msgId?.isNotEmpty==true){
      where.add('msgId=?');
      whereArgs.add(msgId);
    }
    if(where.isEmpty) throw '参数不能为空';
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    return database.update('message',data,where:where.join(' and '),whereArgs:whereArgs);
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

class SfMessageType{
  static const String image = 'image';
  static const String notify = 'notify';
  static const String recall = 'recall';
  static const String system = 'system';
  static const String text = 'text';
  static const String voice = 'voice';
}