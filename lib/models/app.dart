import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_foundation/utils/file_helper.dart';

class SfApp{
  static const ColorFilter greyColorFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);
  static Future<String> prepareSound(String url) async {
    if(!SfFileHelper.isUrl(url)){
      var dir = SfFileHelper.getDirname(url);
      var audioCache = AudioCache(prefix:'$dir/');
      var uri = await audioCache.load(SfFileHelper.getFileName(url));
      url = uri.toString();
    }
    return url;
  }
  static Future<AudioPlayer> playSound(String url,{double volume=1.0,bool loop=false,ValueChanged<AudioPlayer>? onStopped}) async {
    url = await prepareSound(url);
    late StreamSubscription stateSubscription;
    var player = new AudioPlayer();
    stateSubscription = player.onPlayerStateChanged.listen((x){
      if(x==PlayerState.stopped||x==PlayerState.completed){
        stateSubscription.cancel();
        onStopped?.call(player);
        player.dispose();
      }
    });
    if(loop) player.setReleaseMode(ReleaseMode.loop);
    player.play(UrlSource(url));
    return player;
  }
}