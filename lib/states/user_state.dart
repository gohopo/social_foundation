import 'package:flutter/foundation.dart';
import 'package:social_foundation/models/user.dart';

class SfUserState<TUser extends SfUser> with ChangeNotifier{
  Map<String,TUser> _users = {};
  String _curUserId;

  TUser operator [](String userId) => _users[userId];
  String get curUserId => _curUserId;
  TUser get curUser => _users[_curUserId];
  Future<TUser> queryUser(String userId,bool fetch) async => this[userId];
  void updateStateUser(dynamic user) => setUser(user);
  @protected
  void setCurUser(TUser user){
    _curUserId = user?.userId;
    setUser(user);
  }
  @protected void setUser(TUser user){
    if(user != null) _users[user.userId] = user;
    notifyListeners();
  }
}