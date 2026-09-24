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

abstract class SfMessage extends SfMessageBase{
  String? msg;
  late String msgType;
  int? receiptTimestamp;
  late int status;
  SfMessage(super.data);
  @override
  void populate(Map data){
    super.populate(data);
    msg = data['msg'];
    msgType = data['msgType']??SfMessageType.text;
    receiptTimestamp = data['receiptTimestamp'];
    status = data['status']??SfMessageStatus.none;
  }
  @override
  Map<String,dynamic> toJson(){
    var map = super.toJson();
    map['msg'] = msg;
    map['msgType'] = msgType;
    map['receiptTimestamp'] = receiptTimestamp;
    map['status'] = status;
    return map;
  }
  List<InlineSpan> get des{
    switch(msgType){
      case SfMessageType.text:
        return msg!=null ? [TextSpan(text:msg)] : [];
      case SfMessageType.image:
        return [TextSpan(text:'[图片]')];
      case SfMessageType.voice:
        return [TextSpan(text:'[声音]')];
      case SfMessageType.system:
        return [TextSpan(text:'[系统]')];
      case SfMessageType.notify:
        return [TextSpan(text:'[通知]')];
      case SfMessageType.recall:
        return [TextSpan(text:'[已撤回]')];
      default:
        return [];
    }
  }
  String get origin => json.encode({
    'msg': msg,
    'msgType': msgType,
    'msgExtra': msgExtra
  });
  static Future delete(int id) => SfSyncEntity.delete('message',where:'id=?',whereArgs:[id]);
  static Future deleteAll(String ownerId,String convId) async {
    var result = await SfSyncEntity.delete('message',where:'ownerId=? and convId=?',whereArgs:[ownerId,convId]);
    SfMessageClearEvent(convId:convId).emit();
    return result;
  }
  String resolveFileUri() => msgExtra['fileKey']!=null ? SfAliyunOss.getFileUrl(msgType,msgExtra['fileKey']) : (attribute['filePath'] ?? '');
  ImageProvider? resolveImage() => msgExtra['fileKey']!=null ? SfCacheManager.provider(SfAliyunOss.getImageUrl(msgExtra['fileKey'])) as ImageProvider : (attribute['filePath']!=null ? FileImage(File(attribute['filePath'])) : null);
  Future save() async {
    if(id!=null) return update(data:toDB(),id:id);
    var count = await update(data:toDB(),msgId:msgId,ownerId:ownerId);
    if(count>0) return;
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    this.id = await database.insert('message',toDB(),conflictAlgorithm:ConflictAlgorithm.replace);
  }
  static Future saveAll<TMessage extends SfMessage>(List<TMessage> messages) async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    var batch = database.batch();
    for(var message in messages){
      if(message.id!=null){
        batch.update('message',message.toDB(),where:'id=?',whereArgs:[message.id]);
      }
      else if(message.msgType==SfMessageType.recall){
        batch.update('message',message.toDB(),where:'ownerId=? and msgId=?',whereArgs:[message.ownerId,message.msgId]);
      }
      else{
        batch.insert('message',message.toDB(),conflictAlgorithm:ConflictAlgorithm.replace);
      }
    }
    var results = await batch.commit();
    for(var i=0;i<messages.length;++i){
      var message = messages[i];
      if(message.msgType==SfMessageType.recall) continue;
      message.id ??= results[i] as int;
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
  static Future<int> update({int? id,String? ownerId,String? msgId,required Map<String,dynamic> data}) async {
    List<String> where=[];List<Object?> whereArgs=[];
    if(id!=null){
      where.add('id=?');
      whereArgs.add(id);
    }
    if(msgId?.isNotEmpty==true){
      where.add('ownerId=?');
      whereArgs.add(ownerId ?? SfLocatorManager.userState.curUserId);
      where.add('msgId=?');
      whereArgs.add(msgId);
    }
    if(where.isEmpty) return 0;
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    return database.update('message',data,where:where.join(' and '),whereArgs:whereArgs);
  }
}

abstract class SfMessageBase extends SfEntity{
  late Map attribute;
  late String convId;
  late String fromId;
  int? id;
  late Map msgExtra;
  String? msgId;
  late String ownerId;
  late int timestamp;
  SfMessageBase(super.data);
  @override
  void populate(Map data){
    attribute = <dynamic,dynamic>{...data['attribute']??{}};
    convId = data['convId']??'';
    fromId = data['fromId']??'';
    id = data['id'];
    msgExtra = <dynamic,dynamic>{...data['msgExtra']??{}};
    msgId = data['msgId'];
    ownerId = data['ownerId']??SfLocatorManager.userState.curUserId??'';
    timestamp = data['timestamp']??0;
  }
  @override
  void populateDB(Map data){
    super.populateDB({
      ...data,
      'attribute': json.decode(data['attribute']??'{}'),
      'msgExtra': json.decode(data['msgExtra']??'{}')
    });
  }
  @override
  Map<String,dynamic> toDB(){
    var map = toJson();
    map['attribute'] = json.encode(attribute);
    map.remove('id');
    map['msgExtra'] = json.encode(msgExtra);
    return map;
  }
  @override
  Map<String,dynamic> toJson() => {
    'attribute': attribute,
    'convId': convId,
    'fromId': fromId,
    'id': id,
    'msgExtra': msgExtra,
    'msgId': msgId,
    'ownerId': ownerId,
    'timestamp': timestamp,
  };
  bool get fromOwner => fromId==ownerId;
  bool get transient => msgExtra['transient']??false;
  @override
  bool equals(covariant SfMessageBase other) => msgId!=null&&msgId==other.msgId || id!=null&&id==other.id || super.equals(other);
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