import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioPlayerModel extends SfViewState{
  SfAudioPlayerModel({
    this.uri,
    this.earpieceMode = false,
    this.compatible = false
  });
  String uri;
  bool earpieceMode;
  bool compatible;
  AudioPlayer player = new AudioPlayer();
  StreamSubscription _stateSubscription;
  StreamSubscription _positionSubscription;
  int position = 0;
  static SfAudioPlayerModel playingVM;
  
  bool get isPlaying => player.state==PlayerState.PLAYING;
  Future play() async {
    if(!compatible) await playingVM?.stop();
    return player.play(uri);
  }
  Future pause(){
    return player.pause();
  }
  Future stop(){
    return player.stop();
  }
  void setGlobal(bool enable){
    if(compatible) return;
    playingVM = enable ? this : null;
  }
  void onPlayerStateChanged(PlayerState s){
    setGlobal(false);
    if(s!=PlayerState.PAUSED) position = 0;
    notifyListeners();
  }
  void onAudioPositionChanged(Duration p){
    setGlobal(true);
    position = p.inMilliseconds;
    notifyListeners();
  }

  Future initData() async {
    _stateSubscription = player.onPlayerStateChanged.listen(onPlayerStateChanged);
    _positionSubscription = player.onAudioPositionChanged.listen(onAudioPositionChanged);
    
    if(earpieceMode) await player.earpieceOrSpeakersToggle();
  }
  void dispose(){
    player.dispose();
    _stateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  void onRefactor(newState) async {
    var state = newState as SfAudioPlayerModel;
    if(uri!=state.uri){
      uri = state.uri;
      await player.setUrl(uri);
    }
    if(earpieceMode!=state.earpieceMode){
      earpieceMode = state.earpieceMode;
      await player.earpieceOrSpeakersToggle();
      if(!isPlaying) play();
    }
  }
  bool get wantKeepAlive => isPlaying;
}