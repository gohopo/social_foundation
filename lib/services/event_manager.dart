import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/message.dart';

class _SfEventBase{
  List<String> handledTags = [];
}

class SfEvent<T extends _SfEventBase> extends _SfEventBase{
  StreamSubscription _subscription;
  
  void listen(void onData(T event),{bool onWhere(T event)}){
    _subscription = GetIt.instance<EventBus>().on<T>().listen((event){
      if(onWhere==null || onWhere(event)) onData(event);
    });
  }
  void emit(){
    GetIt.instance<EventBus>().fire(this);
  }
  void dispose(){
    _subscription?.cancel();
    _subscription = null;
  }
}

class SfClientDisconnectedEvent extends SfEvent<SfClientDisconnectedEvent>{}
class SfClientResumingEvent extends SfEvent<SfClientResumingEvent>{}

class SfMessageEvent extends SfEvent<SfMessageEvent>{
  SfMessage message;
  bool isNew;
  SfMessageEvent({this.message,this.isNew});
}