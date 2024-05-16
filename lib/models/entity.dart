import 'package:collection/collection.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfEntity{
  SfEntity(Map data){
    populate(data);
  }
  void populate(Map data){}
  void populateWith(SfEntity other) => populate(other.toJson());
  SfEntity fromJson(Map data) => noSuchMethod(Invocation.method(Symbol('fromJson'),null));
  Map<String,dynamic> toJson() => {};
  SfEntity fromDB(Map data) => fromJson(data);
  Map<String,dynamic> toDB() => toJson();
  bool equals(SfEntity other) => this==other;
}

abstract class SfSyncEntity extends SfEntity{
  late String userId;
  late int modifiedAt;
  late int isDeleted;
  SfSyncEntity(super.data);
  void populate(Map data){
    super.populate(data);
    userId = data['userId']??SfLocatorManager.userState.curUserId;
    modifiedAt = data['modifiedAt']??0;
    isDeleted = data['isDeleted']??0;
  }
  Map<String,dynamic> toJson() => {
    ...super.toJson(),
    'userId': userId,
    'modifiedAt': modifiedAt,
    'isDeleted': isDeleted,
  };
  bool get isSynced => modifiedAt<=(SfLocatorManager.storageManager.sharedPreferences.getJson(SfStorageManagerKey.syncedAtMap)[syncTable] ?? 0);
  String get syncTable => noSuchMethod(Invocation.getter(Symbol('syncTable')));
  static Future delete(String table,{String? where, List<Object?>? whereArgs}) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.delete(table,where:where,whereArgs:whereArgs);
  }
  static Future deleteAll(String table) => delete(table);
  static Future<Map<String,List<SfSyncEntity>>> sync({required List<SfSyncEntity> schemas,bool? onlyWhenModified}) async {
    if(schemas.isNotEmpty!=true) return {};
    var syncedAtMap = SfLocatorManager.storageManager.sharedPreferences.getJson(SfStorageManagerKey.syncedAtMap);
    var syncingMap = {};
    for(var schema in schemas){
      var list = await schema.queryUnsyncedList(syncedAtMap[schema.syncTable]);
      syncingMap[schema.syncTable] = {
        'at':syncedAtMap[schema.syncTable],'list':list
      };
      if(list.isNotEmpty) syncedAtMap[schema.syncTable] = DateTime.now().millisecondsSinceEpoch;
    }
    if(onlyWhenModified==true && syncingMap.values.every((x) => x['list'].isEmpty)) return {};
    var result = await SfLocatorManager.requestManager.invokeFunction('app','sync',{'syncingMap':syncingMap});
    Map<String,List<SfSyncEntity>> tableMap = {};
    for(var x in Map.from(result['map']).entries){
      var schema = schemas.firstWhereOrNull((schema) => schema.syncTable==x.key);
      if(schema==null) continue;
      List<SfSyncEntity> list = x.value['list'].map<SfSyncEntity>((y) => schema.fromJson(y)).toList();
      await Future.wait(list.map((y) => y.saveToDB()));
      tableMap[schema.syncTable] = list;
      if(list.isNotEmpty) syncedAtMap[schema.syncTable] = DateTime.now().millisecondsSinceEpoch;
    }
    SfLocatorManager.storageManager.sharedPreferences.setJson(SfStorageManagerKey.syncedAtMap,syncedAtMap);
    return tableMap;
  }
  Future<List<SfSyncEntity>> queryUnsyncedList(int? lastSyncedAt) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    var result = await database.query(syncTable,where:'userId=? and modifiedAt>?',whereArgs:[SfLocatorManager.userState.curUserId,lastSyncedAt??0]);
    return result.map(fromDB).cast<SfSyncEntity>().toList();
  }
  Future saveToDB() async {
    var count = await updateToDB();
    if(count>0) return;
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.insert(syncTable,toDB(),conflictAlgorithm:ConflictAlgorithm.replace);
  }
  Future<int> updateToDB() async => 0;
}