import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/index.dart';
import 'package:sqflite/sqflite.dart';

class StorageManager extends SfStorageManager{
  static StorageManager get instance => GetIt.instance<SfStorageManager>();

  @protected
  void onCreateDatabase(Database database,int version) async {
    database.execute('create table user(userId text primary key,nickName text,icon text)');
    database.execute('create table conversation(id integer primary key autoincrement,ownerId text,convId text,creator text,members text,unreadMessagesCount integer,lastMessage text,lastMessageAt integer)');
    database.execute('create table message(id integer primary key autoincrement,ownerId text,msgId text,convId text,fromId text,timestamp integer,status text,receiptTimestamp integer,attribute text,msg text,msgType text,msgExtra text)');
  }
  @protected
  void onUpgradeDatabase(Database database,int oldVersion, int newVersion) async {

  }
}