import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_foundation/models/app.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAppState extends SfViewState{
  //主题
  bool _userDarkMode;//用户选择的明暗模式
  MaterialColor _themeColor;//当前主题颜色
  int _fontIndex;//当前字体索引
  List<String> fontList = ['system'];
  int get fontIndex => _fontIndex;
  void switchTheme({bool userDarkMode, MaterialColor color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeColor = color ?? _themeColor;
    notifyListeners();
    saveTheme(_userDarkMode, _themeColor);
  }
  void switchRandomTheme({Brightness brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      color: Colors.primaries[colorIndex],
    );
  }
  void switchFont(int index) {
    _fontIndex = index;
    switchTheme();
    saveFontIndex(index);
  }
  ThemeData themeData({bool platformDarkMode: false}){
    var isDark = platformDarkMode || _userDarkMode;
    return onThemeData(ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColorBrightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      primarySwatch: _themeColor,
      accentColor: isDark ? _themeColor[700] : _themeColor,
      fontFamily: fontList[fontIndex]
    ));
  }
  Future saveTheme(bool userDarkMode, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      SfLocatorManager.storageManager.sharedPreferences.setAppBool(SfStorageManagerKey.themeUserDarkMode, userDarkMode),
      SfLocatorManager.storageManager.sharedPreferences.setAppInt(SfStorageManagerKey.themeColorIndex, index)
    ]);
  }
  Future saveFontIndex(int index) async {
    await SfLocatorManager.storageManager.sharedPreferences.setAppInt(SfStorageManagerKey.fontIndex, index);
  }
  InputDecorationTheme inputDecorationTheme(ThemeData theme){
    var width = 0.5;
    return InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 14),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.errorColor)),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.7, color: theme.errorColor)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.primaryColor)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.dividerColor)),
      border: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.dividerColor)),
      disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.disabledColor)),
    );
  }
  String fontName(index) {
    return fontList[index];
  }
  ThemeData onThemeData(ThemeData themeData){
    return themeData.copyWith(
      brightness: themeData.brightness,
      accentColor: themeData.accentColor,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: _themeColor,
        brightness: themeData.brightness,
      ),
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: _themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      textTheme: themeData.textTheme.copyWith(
        //subhead: themeData.textTheme.subhead.copyWith(textBaseline: TextBaseline.alphabetic)
      ),
      textSelectionTheme: themeData.textSelectionTheme.copyWith(
        cursorColor: themeData.accentColor,
        selectionColor: themeData.accentColor.withAlpha(60),
        selectionHandleColor: themeData.accentColor.withAlpha(60),
      ),
      toggleableActiveColor: themeData.accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
      inputDecorationTheme: inputDecorationTheme(themeData),
    );
  }
  void showError(error){}
  //通知
  List<String> notifyList = [];
  bool isNotifyUnread(String notifyType) => notifyList.contains(notifyType);
  Future queryNotifyList() async {
    notifyList = await SfApp.queryNotifyList(SfLocatorManager.userState.curUserId);
    notifyListeners();
    processNotifyList();
  }
  void addNotify(String notifyType) async {
    if(notifyType==null) return;
    notifyList.removeWhere((data) => data==notifyType);
    await Future.delayed(Duration(milliseconds:3000));//通知延迟,因为多元索引同步有延迟
    notifyList.add(notifyType);
    notifyListeners();
    processNotifyList();
  }
  void removeNotify(String notifyType) {
    if(notifyType==null || !notifyList.contains(notifyType)) return;
    notifyList.removeWhere((data) => data==notifyType);
    delayedNotifyListeners(500);
    SfApp.removeNotify(SfLocatorManager.userState.curUserId, notifyType);
  }
  void processNotifyList(){}
  //关键字
  String filterKeyword(String content) => content;

  @override
  Future initData() async {
    _userDarkMode = SfLocatorManager.storageManager.sharedPreferences.getAppBool(SfStorageManagerKey.themeUserDarkMode) ?? false;
    _themeColor = Colors.primaries[SfLocatorManager.storageManager.sharedPreferences.getAppInt(SfStorageManagerKey.themeColorIndex) ?? 5];
    _fontIndex = SfLocatorManager.storageManager.sharedPreferences.getAppInt(SfStorageManagerKey.fontIndex) ?? 0;
  }
}