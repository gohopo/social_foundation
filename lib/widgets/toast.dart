import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_foundation/pages/photo_viewer.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/utils/image_helper.dart';
import 'package:social_foundation/widgets/animation.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';

typedef SfDialogBuilder = Widget Function(SfDialog dialog);

class SfDialog{
  CancelFunc? _cancelFunc;
  
  void onShow({required SfDialogBuilder builder,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapAnimation,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? crossPage,bool? allowClick,bool? clickClose,bool? ignoreContentClick,bool? onlyOne,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => BotToast.showAnimationWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return builder(this);
    },
    animationDuration: animationDuration ?? Duration(milliseconds:250),
    animationReverseDuration: animationReverseDuration,
    wrapAnimation: wrapAnimation ?? (controller,cancelFunc,widget) => Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => widget
          )
        ],
      )
    ),
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
  void showPhotoViewer({required List<ImageProvider> images,int? index,String? heroPrefix,ExtendedPageController? controller,bool? canSave,SfLoadStateChanged? loadStateChanged}) => onShowCustom(
    groupKey: 'SfPhotoGalleryViewer',
    wrapToastAnimation: (controller,__,widget) => SfFadeAnimation(controller:controller,child:widget),
    animationDuration:Duration(milliseconds:100),animationReverseDuration:Duration(milliseconds:100),
    builder: (dialog) => SfPhotoGalleryViewer(
      dialog:dialog,images:images,index:index,heroPrefix:heroPrefix,controller:controller,
      canSave:canSave,loadStateChanged:loadStateChanged
    )
  );
  void showPhotoViewer2({required List<String> imageKeys,int? index,String? heroPrefix,ExtendedPageController? controller,bool? canSave,SfLoadStateChanged? loadStateChanged}) => showPhotoViewer(
    images:imageKeys.map((fileKey) => SfCacheManager.provider(SfAliyunOss.getImageUrl(fileKey))).toList(),
    index:index,heroPrefix:heroPrefix,controller:controller,canSave:canSave,
    loadStateChanged:(index,state) => state.extendedImageLoadState==LoadState.completed ? null : Center(
      child: SfCachedImage(
        imagePath: SfAliyunOss.getImageUrl(imageKeys[index],width:500,height:500),
        fit: BoxFit.cover,
      )
    )
  );

  Widget buildDialog({Widget? child,BoxConstraints? constraints}){
    return Container(
      constraints: constraints ?? BoxConstraints.tightFor(width:250),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: child
    );
  }
  Widget buildTitle(String title) => Text(title,style:TextStyle(fontSize:18,color:Colors.black.withOpacity(0.85)),textAlign:TextAlign.center);
  Widget buildContent(String content) => Container(
    margin: EdgeInsets.only(left:7,bottom:10),
    child: Text(content,style:TextStyle(fontSize:14,color:Color.fromARGB(255,51,51,51))),
  );
  Widget buildAction(int index,String action) => Container(
    margin: EdgeInsets.symmetric(horizontal:15),
    padding: EdgeInsets.symmetric(horizontal:14,vertical:4),
    decoration: BoxDecoration(
      border: Border.all(width:0.5,color:Color.fromARGB(255,217,217,217)),
      borderRadius: BorderRadius.circular(2)
    ),
    child: Text(action,style:TextStyle(fontSize:14,color:Color.fromARGB(255,51,51,51))),
  );
  Widget buildSheetActionContainer({required int length,int? index,Widget? child,required bool split,bool? splitLast}) => Container(
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
  Widget buildSheetAction(int index,String action) => Container(
    height: 44,
    alignment: Alignment.center,
    child: Text(action,style:TextStyle(fontSize:15,color:Color.fromARGB(255,51,51,51))),
  );

  Future<File?> onPickImage({double maxWidth=1000,double maxHeight=1000,int imageQuality=75,int maxFileSize=6}) async {
    var index = await onShowSheet(['从相册选择照片','拍照','取消'],splitLast:true);
    if(index == 2) return null;
    return SfImageHelper.pickImage(
      source: [ImageSource.gallery,ImageSource.camera][index],
      maxWidth:maxWidth,maxHeight:maxHeight,imageQuality:imageQuality,maxFileSize:maxFileSize
    );
  }
  Future onShowAlert(String title,String content,String action,{Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowConfirm(title,content,[action],animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration);
  Future<int> onShowConfirm(String? title,String content,List<String> actions,{Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowCustomConfirm(
    title: title!=null ? buildTitle(title) : null,
    content: buildContent(content),
    actions: actions.asMap().keys.map((index) => buildAction(index,actions[index])).toList(),
    animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomConfirm({Widget? title,Widget? content,required List<Widget> actions,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}){
    var completer = Completer<int>();
    onShowFrame(
      title: title,
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
  Future<int> onShowSheet(List<String> actions,{String? title,bool? split,bool? splitLast,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowSheetEnhanced(
    title: title!=null ? buildTitle(title) : null,
    actions: actions.asMap().keys.map((index) => buildSheetAction(index,actions[index])).toList(),
    split:split,splitLast:splitLast,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowSheetEnhanced({Widget? title,required List<Widget> actions,bool? split,bool? splitLast,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowCustomSheet(
    actions: actions.asMap().keys.map((index) => buildSheetActionContainer(
      length: actions.length,
      index: index,
      child: actions[index],
      split:split??true,splitLast:splitLast
    )).toList(),
    title:title,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
    clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomSheet({Widget? title,required List<Widget> actions,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}){
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
  void onShowFrame({Widget? title,Widget? body,Widget? footer,Alignment? alignment,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShowCustomFrame(
    header: Padding(
      padding: EdgeInsets.only(bottom:3),
      child: title,
    ),
    body:body,footer:footer,alignment:alignment,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor,duration:duration
  );
  void onShowCustomFrame({Widget? header,Widget? body,Widget? footer,BoxConstraints? constraints,Alignment? alignment,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShowCustom(
    builder: (_) => Align(
      alignment: alignment ?? Alignment.center,
      child: buildDialog(
        constraints: constraints,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
  void onShowCustom({required SfDialogBuilder builder,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? allowClick,bool? clickClose,bool? ignoreContentClick,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShow(
    builder: builder,
    animationDuration: animationDuration,
    animationReverseDuration: animationReverseDuration,
    wrapToastAnimation: wrapToastAnimation,
    key: key,
    groupKey: groupKey??'SfEasyDialog',
    allowClick: allowClick,
    clickClose: clickClose,
    ignoreContentClick: ignoreContentClick,
    onClose: onClose,
    backgroundColor: backgroundColor,
    duration: duration
  );
}

class SfToast{
  void onShowText(String text) => onShowCustomText(text);
  void onShowCustomText(String text,{Color? backgroundColor,AlignmentGeometry? align,EdgeInsetsGeometry? contentPadding,Color? contentColor,BorderRadiusGeometry? borderRadius,TextStyle? textStyle}) => BotToast.showText(
    text: text,
    backgroundColor: backgroundColor ?? Colors.transparent,
    align: align ?? const Alignment(0, 0.8),
    contentPadding: contentPadding ?? EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7),
    contentColor: contentColor ?? Colors.black54,
    borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8)),
    textStyle: textStyle ?? TextStyle(fontSize: 17, color: Colors.white)
  );
  void onShowLoading({double? size,Color? color}) => onShowCustomLoading(SpinKitCircle(
    size: size ?? 50.0,
    color: color ?? Colors.white,
  ));
  void onShowCustomLoading(Widget loadingWidget,{Color? backgroundColor,Alignment? align}) => BotToast.showCustomLoading(
    backgroundColor: backgroundColor ?? Colors.black26,
    align: align ?? Alignment.center,
    toastBuilder: (_) => loadingWidget,
  );
  void onCloseAllLoading() => BotToast.closeAllLoading();
}