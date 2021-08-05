import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/file_helper.dart';

class SfApp{
  static Future<List<String>> queryNotifyList(String userId) async {
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'queryNotifyList', {
      'userId':userId
    });
    return result['rows'].map((data) => data['notifyType']).cast<String>().toList();
  }
  static Future sendNotify(String userId,String otherId,String notifyType){
    return SfLocatorManager.requestManager.invokeFunction('app', 'sendNotify', {
      'userId':userId,'otherId':otherId,'notifyType':notifyType
    });
  }
  static Future removeNotify(String userId,String notifyType){
    return SfLocatorManager.requestManager.invokeFunction('app', 'removeNotify', {
      'userId':userId,'notifyType':notifyType
    });
  }
  static Future<String> prepareSound(String url) async {
    if(!SfFileHelper.isUrl(url)){
      var dir = SfFileHelper.getDirname(url);
      var audioCache = AudioCache(prefix:'$dir/');
      var uri = await audioCache.load(SfFileHelper.getFileName(url));
      url = uri.toString();
    }
    return url;
  }
  static Future<AudioPlayer> playSound(String url,{double volume=1.0,bool loop=false,ValueChanged<AudioPlayer> onStopped}) async {
    url = await prepareSound(url);
    StreamSubscription stateSubscription;
    var player = new AudioPlayer();
    stateSubscription = player.onPlayerStateChanged.listen((x){
      if(x==PlayerState.STOPPED||x==PlayerState.COMPLETED){
        stateSubscription.cancel();
        onStopped?.call(player);
        player.dispose();
      }
    });
    if(loop) player.setReleaseMode(ReleaseMode.LOOP);
    player.play(url);
    return player;
  }
}