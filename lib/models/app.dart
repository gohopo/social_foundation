abstract class SfApp{
  Future<List<String>> queryNotifyList(String userId);
  Future removeNotify(String userId,String notifyType);
}