import 'package:flutter/foundation.dart';
import 'package:social_foundation/models/user.dart';

class SfUserState<TUser extends SfUser> with ChangeNotifier{
  Map<String,TUser> _users = {};
  String _curUserId;

  TUser operator [](String userId) => _users[userId];
  String get curUserId => _curUserId;
  Future<TUser> queryUser(String userId) async => this[userId];
  @protected
  void setCurUser(TUser user){
    _curUserId = user.userId;
    setUser(user);
  }
  @protected void setUser(TUser user){
    _users[user.userId] = user;
    notifyListeners();
  }
}