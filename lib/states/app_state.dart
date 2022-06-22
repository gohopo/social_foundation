import 'package:flutter/material.dart';
import 'package:social_foundation/models/app.dart';
import 'package:social_foundation/models/theme.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfThemeState<TTheme extends SfTheme> extends SfViewState{
  List<TTheme> _themes = [];
  int _themeIndex = 0;
  TTheme get theme => _themes[_themeIndex];
  ThemeData themeData(ThemeData themeData) => onThemeData(themeData.copyWith(
    colorScheme: themeData.colorScheme.copyWith(
      primary:theme.primary,secondary:theme.primary,
    ),
    scaffoldBackgroundColor: theme.pageBackground,
    dividerColor: theme.divider,
    toggleableActiveColor: theme.primary,
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
      headline6: TextStyle(fontSize:16,color:Color.fromRGBO(0,0,0,1)),
      bodyText1: TextStyle(fontSize:12,color:Color.fromRGBO(0,0,0,1)),
    ),
    primaryIconTheme: themeData.primaryIconTheme.copyWith(
      color: Color.fromRGBO(51,51,51,1)
    ),
    switchTheme: themeData.switchTheme.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    )
  ));
  
  Future initData() async {
    _themes.add(defaultTheme);
  }
  TTheme get defaultTheme => noSuchMethod(Invocation.getter(Symbol('defaultTheme')));
  ThemeData onThemeData(ThemeData themeData) => themeData;
}

class SfAppState<TTheme extends SfTheme> extends SfThemeState<TTheme>{
  void showError(error){}
  //通知
  List<String> notifyList = [];
  bool isNotifyUnread(String notifyType) => notifyList.contains(notifyType);
  Future queryNotifyList() async {
    notifyList = await SfApp.queryNotifyList(SfLocatorManager.userState.curUserId);
    notifyListeners();
    processNotifyList();
  }
  void addNotify(String? notifyType) async {
    if(notifyType==null) return;
    notifyList.removeWhere((data) => data==notifyType);
    await Future.delayed(Duration(milliseconds:3000));//通知延迟,因为多元索引同步有延迟
    notifyList.add(notifyType);
    notifyListeners();
    processNotifyList();
  }
  void removeNotify(String? notifyType) {
    if(notifyType==null || !notifyList.contains(notifyType)) return;
    notifyList.removeWhere((data) => data==notifyType);
    delayedNotifyListeners(500);
    SfApp.removeNotify(SfLocatorManager.userState.curUserId, notifyType);
  }
  void processNotifyList(){}
  //关键字
  String? filterKeyword(String? content) => content;
  Future sync({bool? onlyWhenModified}) async {}
}