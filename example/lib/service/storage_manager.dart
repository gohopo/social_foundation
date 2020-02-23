import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class StorageManager {
  static StorageManager get instance => GetIt.instance<StorageManager>();
  StorageManager() {
    _init();
  }
  Directory temporaryDirectory;
  Database _database;

  void _init() async {
    temporaryDirectory = await getTemporaryDirectory();
  }
  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase('social.db',version: getDatabaseVersion(),onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database;
  }
  int getDatabaseVersion(){
    return 1;
  }
  @protected
  void onCreateDatabase(Database database,int version) async {
    database.execute('create table user(userId text primary key,nickName text,icon text)');
    database.execute('create table conversation(ownerId text,convId text,creator text,members text,unreadMessagesCount integer,lastMessage text,lastMessageAt integer)');
    database.execute('create table message(ownerId text,msgId text primary key,convId text,fromId text,timestamp integer,status text,receiptTimestamp integer,msg text,msgType text,attribute text)');
  }
  @protected
  void onUpgradeDatabase(Database database,int oldVersion, int newVersion) async {

  }
}