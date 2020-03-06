import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfStorageManager {
  SfStorageManager({
    this.dbPath = 'social_foundation.db',
    this.dbVersion = 1
  }){
    onInit();
  }
  final String dbPath;
  final int dbVersion;
  Database _database;

  Future<Directory> getCacheDirectory() => getApplicationDocumentsDirectory();
  Future<String> getFileDirectory(String dir) async {
    var cache = await getCacheDirectory();
    return p.join(cache.path,dir);
  }
  Future<String> getImageDirectory() async {
    return getFileDirectory('image');
  }
  Future<String> getVoiceDirectory() async {
    return getFileDirectory('voice');
  }
  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase(dbPath,version:dbVersion,onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database;
  }
  @protected Future<void> onInit() async {
    var cache = await getCacheDirectory();
    await Directory(p.join(cache.path,'image')).create(recursive:true);
    await Directory(p.join(cache.path,'voice')).create(recursive:true);
  }
  @protected void onCreateDatabase(Database database,int version);
  @protected void onUpgradeDatabase(Database database,int oldVersion, int newVersion);
}