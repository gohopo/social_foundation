import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfStorageManager{
  SfStorageManager({
    this.dbPath = 'social_foundation.db',
    this.dbVersion = 1
  });
  final String dbPath;
  final int dbVersion;
  Directory cacheDirectory;
  SharedPreferences sharedPreferences;
  String deviceId;
  Database _database;

  Future init() async {
    cacheDirectory = await getApplicationDocumentsDirectory();
    sharedPreferences = await SharedPreferences.getInstance();
    deviceId = await SfUtils.getDeviceId();
    return onInit();
  }
  String getFileDirectory(String dir) => p.join(cacheDirectory.path,dir);
  String get imageDirectory => getFileDirectory('image');
  String get voiceDirectory => getFileDirectory('voice');
  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase(dbPath,version:dbVersion,onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database;
  }
  Future deleteDirectory(String dir) => Directory(p.join(cacheDirectory.path,dir)).delete(recursive:true);
  Future clear() async {
    await SfCacheManager().emptyCache();
    await deleteDirectory('image');
    await deleteDirectory('voice');
    await onInit();
  }
  
  @protected Future onInit() async {
    await Directory(p.join(cacheDirectory.path,'image')).create(recursive:true);
    await Directory(p.join(cacheDirectory.path,'voice')).create(recursive:true);
  }
  @protected void onCreateDatabase(Database database,int version);
  @protected void onUpgradeDatabase(Database database,int oldVersion, int newVersion);
}

class SfStorageManagerKey{
  static const themeUserDarkMode = 'themeUserDarkMode';
  static const themeColorIndex = 'themeColorIndex';
  static const fontIndex = 'fontIndex';
}