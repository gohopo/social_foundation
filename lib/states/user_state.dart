import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfUserState<TUser extends SfUser> extends SfViewState{
  Map<String,TUser> _users = {};
  String? _curUserId;

  TUser? operator [](String userId) => _users[userId];
  String? get curUserId => _curUserId;
  TUser? get curUser => _users[_curUserId];
  Future<TUser?> queryUser(String userId,bool fetch) async => this[userId];
  Future<TUser?> queryUserEx(bool Function(TUser user) test) async => _users.values.firstWhereOrNull(test);
  void updateStateUser(dynamic user) => setUser(user);
  void updateStateUsers(dynamic users){
    if(users==null) return;
    users.map((user) => updateStateUser(user));
  }
  @protected
  void setCurUser(TUser? user){
    _curUserId = user?.userId;
    setUser(user);
  }
  @protected void setUser(TUser? user){
    if(user != null) _users[user.userId] = user;
    notifyListeners();
  }
}