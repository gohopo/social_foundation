import 'dart:io';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_foundation/models/notify.dart';
import 'package:social_foundation/models/theme.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfThemeState<TTheme extends SfTheme> extends SfViewState{
  List<TTheme> _themes = [];
  int _themeIndex = 0;
  SfThemeState(){
    _themes.add(defaultTheme);
  }
  TTheme get theme => _themes[_themeIndex];
  TTheme get defaultTheme => noSuchMethod(Invocation.getter(Symbol('defaultTheme')));
  ThemeData themeData(ThemeData themeData) => onThemeData(themeData.copyWith(
    colorScheme: themeData.colorScheme.copyWith(
      primary:theme.primary,secondary:theme.primary,
    ),
    scaffoldBackgroundColor: theme.pageBackground,
    dividerColor: theme.divider,
    appBarTheme: themeData.appBarTheme.copyWith(
      backgroundColor:theme.navbarBackground,
      titleTextStyle: TextStyle(fontSize:16,color:Colors.black,fontWeight:FontWeight.w500,height:1),
      centerTitle:true,elevation:0,
      iconTheme: IconThemeData(
        color: Colors.black
      ),
    ),
    inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
      hintStyle: TextStyle(fontSize:14,color:Color.fromRGBO(51,51,51,0.6)),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero
    ),
    primaryTextTheme: themeData.textTheme.copyWith(
      titleLarge: TextStyle(fontSize:16,color:Color.fromRGBO(0,0,0,1)),
      bodyLarge: TextStyle(fontSize:12,color:Color.fromRGBO(0,0,0,1)),
    ),
    primaryIconTheme: themeData.primaryIconTheme.copyWith(
      color: Color.fromRGBO(51,51,51,1)
    ),
    switchTheme: themeData.switchTheme.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateColor.resolveWith((states)=>states.contains(WidgetState.selected)?theme.primary:Color.fromRGBO(234,234,234,1)),
      trackOutlineColor:WidgetStatePropertyAll(Colors.transparent),trackOutlineWidth:WidgetStatePropertyAll(0),
    ),
    tabBarTheme: themeData.tabBarTheme.copyWith(
      dividerHeight: 0
    )
  ));
  ThemeData onThemeData(ThemeData themeData) => themeData;
}

class SfAppState<TTheme extends SfTheme> extends SfThemeState<TTheme>{
  void showError(error){}
  //通知
  List<SfNotify> notifyList = [];
  SfNotify? getNotify(String notifyType) => notifyList.firstWhereOrNull((x) => x.notifyType==notifyType);
  int getNotifyCount(String notifyType) => getNotify(notifyType)?.count ?? 0;
  bool isNotifyUnread(String notifyType) => getNotifyCount(notifyType)>0;
  Future queryNotifyList() async {
    notifyList = await SfNotify.queryNotifyList(SfLocatorManager.userState.curUserId);
    notifyListeners();
    processNotifyList();
  }
  void addNotify({String? notifyType,String? fromId}) async {
    if(notifyType==null) return;
    await Future.delayed(Duration(milliseconds:3000));//通知延迟,因为多元索引同步有延迟
    var notify = notifyList.firstWhereOrNull((x) => x.notifyType==notifyType);
    if(notify==null){
      notify = SfNotify({'notifyType':notifyType});
      notifyList.add(notify);
    }
    else{
      notify.count++;
    }
    if(fromId!=null) notify.fromId = fromId;
    notifyListeners();
    processNotifyList();
  }
  void removeNotify(String? notifyType) {
    if(notifyType==null || !notifyList.any((x) => x.notifyType==notifyType)) return;
    notifyList.removeWhere((x) => x.notifyType==notifyType);
    delayedNotifyListeners(500);
    SfNotify.removeNotify(SfLocatorManager.userState.curUserId, notifyType);
  }
  void processNotifyList(){}
  //关键字
  String? filterKeyword(String? content) => content;
  Future sync({bool? onlyWhenModified}) async {}
  //权限
  Future<PermissionStatus> getPermission(Permission permission) async {
    if(permission==Permission.photos && Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if(androidInfo.version.sdkInt<=32) permission = Permission.storage;
    }

    var status = await permission.status;
    var confirmedPermissions = SfLocatorManager.storageManager.sharedPreferences.getAppArray(SfStorageManagerKey.confirmedPermissions).cast<int>().toList();
    if(!status.isGranted || !confirmedPermissions.contains(permission.value)){
      if(!confirmedPermissions.contains(permission.value)) SfLocatorManager.storageManager.sharedPreferences.setAppArray(SfStorageManagerKey.confirmedPermissions,confirmedPermissions..add(permission.value));
      if(await confirmPermission(permission,status) && !status.isGranted) status = await permission.request();
    }
    return status;
  }
  Future<bool> confirmPermission(Permission permission,PermissionStatus status) async => true;
}