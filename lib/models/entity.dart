import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfEntity{
  bool equals(covariant SfEntity other) => this==other;
}

abstract class SfSyncEntity extends SfEntity{
  String userId;
  int modifiedAt;
  int isDeleted;
  SfSyncEntity(Map data){
    populate(data);
  }
  void populate(Map data){
    userId = data['userId']??SfLocatorManager.userState.curUserId;
    modifiedAt = data['modifiedAt']??0;
    isDeleted = data['isDeleted'];
  }
  void populateWith(covariant SfSyncEntity other) => populate(other.toJson());
  SfSyncEntity fromJson(Map data) => null;
  Map<String,dynamic> toJson() => {
    'userId': userId,
    'modifiedAt': modifiedAt,
    'isDeleted': isDeleted,
  };
  SfSyncEntity fromDB(Map data) => fromJson(data);
  Map<String,dynamic> toDB() => toJson();
  bool get isSynced => modifiedAt<=lastSyncedAt;
  String get syncTable => null;
  static int get lastSyncedAt => SfLocatorManager.storageManager.sharedPreferences.getInt(SfStorageManagerKey.lastSyncedAt);
  static Future<Map<String,List<SfSyncEntity>>> sync({List<SfSyncEntity> schemas}) async {
    if(schemas?.isNotEmpty!=true) return {};
    var unsyncedMap = {};
    for(var schema in schemas){
      var list = await schema.queryUnsyncedList();
      unsyncedMap[schema.syncTable] = {'list':list};
    }
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'sync', {
      'lastSyncedAt':lastSyncedAt,'unsyncedMap':unsyncedMap
    });
    Map<String,List<SfSyncEntity>> entitiesMap = {};
    for(var x in Map.from(result['map']).entries){
      var schema = schemas.firstWhere((schema) => schema.syncTable==x.key,orElse:()=>null);
      if(schema==null) continue;
      List<SfSyncEntity> list = x.value['list'].map<SfSyncEntity>((y) => schema.fromJson(y)).toList();
      await Future.wait(list.map((y) => y.saveToDB()));
      entitiesMap[schema.syncTable] = list;
    }
    SfLocatorManager.storageManager.sharedPreferences.setInt(SfStorageManagerKey.lastSyncedAt,DateTime.now().millisecondsSinceEpoch);
    return entitiesMap;
  }
  Future<List<SfSyncEntity>> queryUnsyncedList() async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    var result = await database.query(syncTable,where:'userId=? and modifiedAt>?',whereArgs:[SfLocatorManager.userState.curUserId,lastSyncedAt]);
    return result.map(fromDB).toList();
  }
  Future saveToDB() async {
    var count = await updateToDB();
    if(count>0) return;
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.insert(syncTable,toDB(),conflictAlgorithm:ConflictAlgorithm.replace);
  }
  Future<int> updateToDB() async => 0;
}