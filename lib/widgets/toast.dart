import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_foundation/widgets/animation.dart';

typedef SfDialogBuilder = Widget Function(SfDialog dialog);

class SfDialog{
  CancelFunc _cancelFunc;
  
  void onShow({SfDialogBuilder builder,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapAnimation,WrapAnimation wrapToastAnimation,UniqueKey key,String groupKey,bool crossPage,bool allowClick,bool clickClose,bool ignoreContentClick,bool onlyOne,VoidCallback onClose,Color backgroundColor,Duration duration}) => BotToast.showAnimationWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return builder(this);
    },
    animationDuration: animationDuration ?? Duration(milliseconds:250),
    animationReverseDuration: animationReverseDuration,
    wrapAnimation: wrapAnimation ?? (controller,cancelFunc,widget) => Material(color:Colors.transparent,child:widget),
    wrapToastAnimation: wrapToastAnimation ?? (controller,cancelFunc,widget) => SfTranslateAnimation(controller:controller,child:widget),
    key: key,
    groupKey: groupKey ?? 'SfDialog',
    crossPage: crossPage ?? true,
    allowClick: allowClick ?? false,
    clickClose: clickClose ?? false,
    ignoreContentClick: ignoreContentClick ?? false,
    onlyOne: onlyOne ?? true,
    onClose: onClose,
    backgroundColor: backgroundColor ?? Color.fromRGBO(221,221,221,0.6),
    duration: duration,
  );
  void close() => _cancelFunc?.call();
}

class SfEasyDialog extends SfDialog{
  @protected Widget buildDialog({Widget child,BoxConstraints constraints}){
    return Container(
      padding: EdgeInsets.all(3),
      constraints: constraints,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: child
    );
  }
  @protected Widget buildTitle(String title) => Padding(
    padding: EdgeInsets.only(left:7),
    child: Text(title,style:TextStyle(fontSize:18,color:Colors.black.withOpacity(0.85))),
  );
  @protected Widget buildContent(String content) => Container(
    margin: EdgeInsets.only(left:7,bottom:10),
    child: Text(content,style:TextStyle(fontSize:14,color:Color.fromARGB(255,51,51,51))),
  );
  @protected Widget buildAction(int index,String action) => Container(
    margin: EdgeInsets.symmetric(horizontal:15),
    padding: EdgeInsets.symmetric(horizontal:14,vertical:4),
    decoration: BoxDecoration(
      border: Border.all(width:0.5,color:Color.fromARGB(255,217,217,217)),
      borderRadius: BorderRadius.circular(2)
    ),
    child: Text(action,style:TextStyle(fontSize:14,color:Color.fromARGB(255,51,51,51))),
  );
  @protected Widget buildSheetActionContainer({int length,int index,Widget child,bool split,bool splitLast}) => Container(
    margin: EdgeInsets.only(left:10,top:splitLast==true&&index==length-1?10:0,right:10,bottom:index==length-1?10:0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: index==0||splitLast==true&&index==length-1?Radius.circular(10):Radius.zero,
        bottom: index==length-1||splitLast==true&&index==length-2?Radius.circular(10):Radius.zero
      )
    ),
    foregroundDecoration: BoxDecoration(
      border: split && index!=0 && (splitLast!=true || index!=length-1) ? Border(top:BorderSide(width:0.5,color:Color.fromARGB(255,232,232,232))) : null
    ),
    child: child
  );
  @protected Widget buildSheetAction(int index,String action) => Container(
    height: 44,
    alignment: Alignment.center,
    child: Text(action,style:TextStyle(fontSize:15,color:Color.fromARGB(255,51,51,51))),
  );

  Future<File> onPickImage({double maxWidth,double maxHeight,int imageQuality}) async {
    var index = await onShowSheet(['从相册选择照片','拍照','取消'],splitLast:true);
    if(index == 2) return null;
    return ImagePicker.pickImage(
      source: [ImageSource.gallery,ImageSource.camera][index],
      maxWidth:maxWidth,maxHeight:maxHeight,imageQuality:imageQuality
    );
  }
  Future onShowAlert(String title,String content,String action,{Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,Color backgroundColor,Duration duration}) => onShowConfirm(title,content,[action],animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration);
  Future<int> onShowConfirm(String title,String content,List<String> actions,{Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,Color backgroundColor,Duration duration}) => onShowCustomConfirm(
    title: title!=null ? buildTitle(title) : null,
    content: buildContent(content),
    actions: actions.asMap().keys.map((index) => buildAction(index,actions[index])).toList(),
    animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomConfirm({Widget title,Widget content,List<Widget> actions,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,Color backgroundColor,Duration duration}){
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
      onClose: () => !completer.isCompleted ? completer.complete(-1) : null,
      animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
    );
    return completer.future;
  }
  Future<int> onShowSheet(List<String> actions,{String title,bool split,bool splitLast,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,Color backgroundColor,Duration duration}) => onShowSheetEnhanced(
    title: title!=null ? buildTitle(title) : null,
    actions: actions.asMap().keys.map((index) => buildSheetAction(index,actions[index])).toList(),
    split:split,splitLast:splitLast,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowSheetEnhanced({Widget title,List<Widget> actions,bool split,bool splitLast,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,UniqueKey key,String groupKey,bool clickClose,Color backgroundColor,Duration duration}) => onShowCustomSheet(
    actions: actions.asMap().keys.map((index) => buildSheetActionContainer(
      length: actions.length,
      index: index,
      child: actions[index],
      split:split??true,splitLast:splitLast
    )).toList(),
    title:title,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
    clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomSheet({Widget title,List<Widget> actions,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,Color backgroundColor,Duration duration}){
    var completer = Completer<int>();
    onShowCustom(
      builder: (_) => Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(title != null) title,
            Column(
              children: actions.asMap().keys.map((index) => GestureDetector(
                onTap: (){
                  this.close();
                  completer.complete(index);
                },
                child: actions[index]
              )).toList(),
            )
          ],
        ),
      ),
      onClose: () => !completer.isCompleted ? completer.complete(-1) : null,
      animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
      clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
    );
    return completer.future;
  }
  void onShowFrame({Widget title,Widget close,Widget body,Widget footer,Alignment alignment,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,VoidCallback onClose,Color backgroundColor,Duration duration}) => onShowCustomFrame(
    header: Container(
      padding: EdgeInsets.only(bottom:3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(title != null) title,
          if(close != null) close
        ],
      ),
    ),
    body:body,footer:footer,alignment:alignment,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor,duration:duration
  );
  void onShowCustomFrame({Widget header,Widget body,Widget footer,BoxConstraints constraints,Alignment alignment,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,bool clickClose,VoidCallback onClose,Color backgroundColor,Duration duration}) => onShowCustom(
    builder: (_) => Align(
      alignment: alignment ?? Alignment.center,
      child: buildDialog(
        constraints: constraints ?? BoxConstraints.tightFor(width:250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(header != null) header,
            if(body != null) body,
            if(footer != null) footer
          ],
        )
      ),
    ),
    animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
    clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor,duration:duration
  );
  void onShowCustom({SfDialogBuilder builder,Duration animationDuration,Duration animationReverseDuration,WrapAnimation wrapToastAnimation,UniqueKey key,String groupKey,bool clickClose,VoidCallback onClose,Color backgroundColor,Duration duration}) => onShow(
    builder: builder,
    animationDuration: animationDuration,
    animationReverseDuration: animationReverseDuration,
    wrapToastAnimation: wrapToastAnimation,
    key: key,
    groupKey: groupKey??'SfEasyDialog',
    clickClose: clickClose,
    onClose: onClose,
    backgroundColor: backgroundColor,
    duration: duration
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
  void onShowLoading({double size,Color color}) => onShowCustomLoading(SpinKitCircle(
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