import 'dart:async';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioPlayerModel extends SfViewState {
  FlutterSound _flutterSound = new FlutterSound();
  StreamSubscription _playerSubscription;
  int position = -1;
  
  Future<void> play(String uri) async {
    await _flutterSound.startPlayer(uri);
    position = 0;
    _playerSubscription = _flutterSound.onPlayerStateChanged.listen((data){
      position = data?.currentPosition?.toInt() ?? -1;
      notifyListeners();
    });
    notifyListeners();
  }
  Future<void> stop() async {
    if(position == -1) return;
    await _flutterSound.stopPlayer();
    position = -1;
    _playerSubscription.cancel();
    notifyListeners();
  }

  @override
  void dispose(){
    stop();
    super.dispose();
  }
}