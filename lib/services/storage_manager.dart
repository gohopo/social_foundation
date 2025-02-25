import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/utils/utils.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfStorageManager{
  SfStorageManager({
    this.dbPath = 'social_foundation.db',
    this.dbVersion = 1
  });
  final String dbPath;
  final int dbVersion;
  late Directory cacheDirectory;
  SfSharedPreferencesStore sharedPreferences = SfSharedPreferencesStore();
  String? device;
  String? deviceId;
  Database? _database;

  Future init() async {
    cacheDirectory = await getApplicationDocumentsDirectory();
    await sharedPreferences.init();
    return onInit();
  }
  Future initDeviceInfo() async {
    var deviceInfo = await SfUtils.getDeviceInfo();
    device = deviceInfo['device'];
    deviceId = deviceInfo['deviceId'];
  }
  String getFileDirectory(String dir) => p.join(cacheDirectory.path,dir);
  String get imageDirectory => getFileDirectory('image');
  String get voiceDirectory => getFileDirectory('voice');
  String get recorderDirectory => getFileDirectory('recorder');
  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase(dbPath,version:dbVersion,onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database!;
  }
  Future deleteDirectory(String? dir){
    if(dir?.isNotEmpty!=true) throw 'dir参数不能为空';
    return Directory(p.join(cacheDirectory.path,dir)).delete(recursive:true);
  }
  Future clear() async {
    await SfCacheManager().emptyCache();
    await deleteDirectory('image');
    await deleteDirectory('recorder');
    await onInit();
  }
  
  @protected Future onInit() async {
    try{
      await deleteDirectory('recorder');
    }
    catch(error){}
    
    await Directory(imageDirectory).create(recursive:true);
    await Directory(voiceDirectory).create(recursive:true);
    await Directory(recorderDirectory).create(recursive:true);
  }
  @protected void onCreateDatabase(Database database,int version);
  @protected void onUpgradeDatabase(Database database,int oldVersion, int newVersion);
}

class SfSharedPreferencesStore{
  late SharedPreferences sp;
  Future init() async => sp = await SharedPreferences.getInstance();
  String _convertUserKey(String key) => '${GetIt.instance<SfUserState>().curUserId}:$key';
  bool containsKey(String key) => containsKeyApp(_convertUserKey(key));
  Future<bool> remove(String key) => removeApp(_convertUserKey(key));
  String? getString(String key,{String? defaultValue}) => getAppString(_convertUserKey(key),defaultValue:defaultValue);
  Future<bool> setString(String key,String value) => setAppString(_convertUserKey(key),value);
  bool getBool(String key,{bool defaultValue=false}) => getAppBool(_convertUserKey(key),defaultValue:defaultValue);
  Future<bool> setBool(String key,bool value) => setAppBool(_convertUserKey(key),value);
  List<String> getStringList(String key) => getAppStringList(_convertUserKey(key));
  Future<bool> setStringList(String key,List<String> value) => setAppStringList(_convertUserKey(key),value);
  int getInt(String key,{int defaultValue=0}) => getAppInt(_convertUserKey(key),defaultValue:defaultValue);
  Future<bool> setInt(String key,int value) => setAppInt(_convertUserKey(key),value);
  double getDouble(String key,{double defaultValue=0}) => getAppDouble(_convertUserKey(key),defaultValue:defaultValue);
  Future<bool> setDouble(String key,double value) => setAppDouble(_convertUserKey(key),value);
  Map getJson(String key) => getAppJson(_convertUserKey(key));
  Future<bool> setJson(String key,Map value) => setAppJson(_convertUserKey(key),value);
  List getArray(String key) => getAppArray(_convertUserKey(key));
  Future<bool> setArray(String key,List value) => setAppArray(_convertUserKey(key),value);
  bool containsKeyApp(String key) => sp.containsKey(key);
  Future<bool> removeApp(String key) => sp.remove(key);
  String? getAppString(String key,{String? defaultValue}) => sp.getString(key) ?? defaultValue;
  Future<bool> setAppString(String key,String value) => sp.setString(key,value);
  bool getAppBool(String key,{bool defaultValue=false}) => sp.getBool(key) ?? defaultValue;
  Future<bool> setAppBool(String key,bool value) => sp.setBool(key,value);
  List<String> getAppStringList(String key) => sp.getStringList(key) ?? [];
  Future<bool> setAppStringList(String key,List<String> value) => sp.setStringList(key,value);
  int getAppInt(String key,{int defaultValue=0}) => sp.getInt(key) ?? defaultValue;
  Future<bool> setAppInt(String key,int value) => sp.setInt(key,value);
  double getAppDouble(String key,{double defaultValue=0}) => sp.getDouble(key) ?? defaultValue;
  Future<bool> setAppDouble(String key,double value) => sp.setDouble(key,value);
  Map getAppJson(String key) => jsonDecode(getAppString(key) ?? '{}');
  Future<bool> setAppJson(String key,Map value) => setAppString(key,jsonEncode(value));
  List getAppArray(String key) => jsonDecode(getAppString(key) ?? '[]');
  Future<bool> setAppArray(String key,List value) => setAppString(key,jsonEncode(value));
}

class SfStorageManagerKey{
  static const String syncedAtMap = 'syncedAtMap';
  static const String confirmedPermissions = 'confirmedPermissions';
}