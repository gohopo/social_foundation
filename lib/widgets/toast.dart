import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SfDialog{
  CancelFunc _cancelFunc;
  
  void onShow({Widget child,UniqueKey key,String groupKey,bool crossPage,bool allowClick,bool clickClose,bool ignoreContentClick,bool onlyOne,FutureFunc closeFunc,VoidCallback onClose,Color backgroundColor,WrapWidget warpWidget,Duration duration}) => BotToast.showEnhancedWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return child;
    },
    key: key,
    groupKey: groupKey ?? 'SfDialog',
    crossPage: crossPage ?? true,
    allowClick: allowClick ?? false,
    clickClose: clickClose ?? false,
    ignoreContentClick: ignoreContentClick ?? false,
    onlyOne: onlyOne ?? true,
    closeFunc: closeFunc,
    onClose: onClose,
    backgroundColor: backgroundColor ?? Colors.black45,
    warpWidget: warpWidget ?? (cancelFunc,widget) => Material(child:widget),
    duration: duration,
  );
  void close() => _cancelFunc?.call();
}

class SfEasyDialog extends SfDialog{
  @protected Widget buildDialog({Widget child,BoxConstraints constraints}){
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10
        ),
        child: Container(
          padding: EdgeInsets.all(5),
          constraints: constraints,
          decoration: BoxDecoration(
            color: Colors.white10,
          ),
          child: child
        )
      ),
    );
  }
  @protected Widget buildTitle(String title) => Text(title,style:TextStyle(fontSize:18,color:Colors.white));
  @protected Widget buildContent(String content) => Container(
    margin: EdgeInsets.only(bottom:10),
    child: Text(content,style:TextStyle(fontSize:14,color:Colors.white70)),
  );
  @protected Widget buildAction(String action) => Container(
    margin: EdgeInsets.symmetric(horizontal:15),
    padding: EdgeInsets.symmetric(horizontal:14,vertical:4),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(4)
    ),
    child: Text(action,style:TextStyle(fontSize:14,color:Colors.white)),
  );

  Future onShowAlert(String title,String content,String action,{bool clickClose,Color backgroundColor}) => onShowConfirm(title,content,[action],clickClose:clickClose,backgroundColor:backgroundColor);
  Future<int> onShowConfirm(String title,String content,List<String> actions,{bool clickClose,Color backgroundColor}) => onShowCustomConfirm(
    title: buildTitle(title),
    content: buildContent(content),
    actions: actions.map(buildAction).toList(),
    clickClose:clickClose,backgroundColor:backgroundColor
  );
  Future<int> onShowCustomConfirm({Widget title,Widget content,List<Widget> actions,bool clickClose,Color backgroundColor}){
    var completer = Completer<int>();
    onShowFrame(
      title: title,
      close: Container(),
      body: content,
      footer: Container(
        margin: EdgeInsets.only(top:10,bottom:3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actions.asMap().keys.map((index) => GestureDetector(
            onTap: (){
              this.close();
              completer.complete(index);
            },
            child: actions[index]
          )).toList(),
        )
      ),
      clickClose:clickClose,backgroundColor: backgroundColor
    );
    return completer.future;
  }
  void onShowFrame({Widget title,Widget close,Widget body,Widget footer,bool clickClose,VoidCallback onClose,Color backgroundColor}) => onShowCustomFrame(
    header: Container(
      padding: EdgeInsets.only(bottom:3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          close
        ],
      ),
    ),
    body:body,footer:footer,clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor
  );
  void onShowCustomFrame({Widget header,Widget body,Widget footer,BoxConstraints constraints,bool clickClose,VoidCallback onClose,Color backgroundColor}) => onShowCustom(
    child: Center(
      child: buildDialog(
        constraints: constraints ?? BoxConstraints.tightFor(width:250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header,body,footer],
        )
      ),
    ),
    clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor
  );
  void onShowCustom({Widget child,String groupKey,bool clickClose,VoidCallback onClose,Color backgroundColor}) => onShow(
    child: child,
    groupKey: groupKey??'SfEasyDialog',
    clickClose: clickClose,
    onClose: onClose,
    backgroundColor: backgroundColor
  );
}

class SfToast{
  void onShowText(String text) => onShowCustomText(text);
  void onShowCustomText(String text,{Color backgroundColor,AlignmentGeometry align,EdgeInsetsGeometry contentPadding,Color contentColor,BorderRadiusGeometry borderRadius,TextStyle textStyle}) => BotToast.showText(
    text: text,
    backgroundColor: backgroundColor ?? Colors.transparent,
    align: align ?? const Alignment(0, 0.8),
    contentPadding: contentPadding ?? EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7),
    contentColor: contentColor ?? Colors.black54,
    borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8)),
    textStyle: textStyle ?? TextStyle(fontSize: 17, color: Colors.white)
  );
  void onShowLoading({double size,Color color}) => onShowCustomLoading(SpinKitCubeGrid(
    size: size ?? 50.0,
    color: color ?? Colors.white,
  ));
  void onShowCustomLoading(Widget loadingWidget,{Color backgroundColor,Alignment align}) => BotToast.showCustomLoading(
    backgroundColor: backgroundColor ?? Colors.black26,
    align: align ?? Alignment.center,
    toastBuilder: (_) => loadingWidget,
  );
  void onCloseAllLoading() => BotToast.closeAllLoading();
}