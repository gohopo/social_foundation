import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioPlayerModel extends SfViewState {
  AudioPlayer _player = new AudioPlayer();
  StreamSubscription _stateSubscription;
  StreamSubscription _positionSubscription;
  int position = -1;
  
  Future<void> play(String uri){
    return _player.play(uri);
  }
  Future<void> stop(){
    return _player.stop();
  }

  @override
  Future<void> initData() async {
    _stateSubscription = _player.onPlayerStateChanged.listen((s){
      position = -1;
      notifyListeners();
    });
    _positionSubscription = _player.onAudioPositionChanged.listen((p){
      position = p.inMilliseconds;
      notifyListeners();
    });
  }
  @override
  void dispose(){
    _player.stop();
    _stateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
}