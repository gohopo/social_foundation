import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/config/storage_manager.dart';
import 'package:social_foundation_example/state/app_state.dart';

class Message extends ChatMessage {
  Message(Map<String,dynamic> data) : ownerId = data['ownerId'],super(data);
  String ownerId;
  static Message fromDB(Map<String,dynamic> data) => Message(data);
  static Future<Message> query(String msgId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('message',where: 'msgId="?"',whereArgs: [msgId],limit: 1);
    return result.length>0 ? Message.fromDB(result[0]) : null;
  }
  static Future<List<Message>> queryAll(String convId,String orderBy,int limit,int offset) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('message',where: 'ownerId="?" and convId="?"',whereArgs: [AppState.instance.curUser.userId,convId],orderBy: orderBy,limit: limit,offset: offset);
    return result.map(Message.fromDB);
  }
  Future<int> insert() async {
    var database = await StorageManager.instance.getDatabase();
    return database.insert('message',toMap());
  }
  Future<int> update() async {
    var database = await StorageManager.instance.getDatabase();
    return database.update('message', toMap(),where: 'msgId="?"',whereArgs: [msgId]);
  }
}