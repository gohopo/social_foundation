import 'package:social_foundation/services/locator_manager.dart';

class SfNotify{
  String notifyType;
  int count;
  SfNotify(Map data):notifyType=data['notifyType'],count=data['count']??1;
  static Future<List<SfNotify>> queryNotifyList(String? userId) async {
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'queryNotifyList', {
      'userId':userId
    });
    return result['rows'].map<SfNotify>((data) => SfNotify(data)).toList();
  }
  static Future sendNotify(String userId,String otherId,String notifyType){
    return SfLocatorManager.requestManager.invokeFunction('app', 'sendNotify', {
      'userId':userId,'otherId':otherId,'notifyType':notifyType
    });
  }
  static Future removeNotify(String? userId,String notifyType){
    return SfLocatorManager.requestManager.invokeFunction('app', 'removeNotify', {
      'userId':userId,'notifyType':notifyType
    });
  }
}