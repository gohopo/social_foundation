import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class StorageManager extends SfStorageManager{
  static StorageManager get instance => GetIt.instance<SfStorageManager>();

  @protected
  void onCreateDatabase(Database database,int version) async {
    database.execute('create table user(userId text primary key,nickName text,icon text,gender integer,bonusPoint integer)');
    database.execute('create table conversation(ownerId text,convId text,creator text,members text,unreadMessagesCount integer,lastMessage text,lastMessageAt integer,top integer)');
    database.execute('create table message(id integer primary key autoincrement,ownerId text,msgId text,convId text,fromId text,timestamp integer,status integer,receiptTimestamp integer,attribute text,msg text,msgType text,msgExtra text)');
  }
  @protected
  void onUpgradeDatabase(Database database,int oldVersion, int newVersion) async {

  }
}