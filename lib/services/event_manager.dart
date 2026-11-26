import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';

class SfEventBase{
  List<String> handledTags = [];
}

class SfEvent<T extends SfEventBase> extends SfEventBase{
  StreamSubscription? _subscription;
  
  void listen(void Function(T event) onData,{bool Function(T event)? onWhere}){
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

class SfCacheClearedEvent extends SfEvent<SfCacheClearedEvent>{}

class SfClientDisconnectedEvent extends SfEvent<SfClientDisconnectedEvent>{}
class SfClientResumingEvent extends SfEvent<SfClientResumingEvent>{}

class SfUnreadMessagesCountUpdatedEvent<TConversation extends SfConversation> extends SfEvent<SfUnreadMessagesCountUpdatedEvent>{
  TConversation? conversation;
  SfUnreadMessagesCountUpdatedEvent({this.conversation});
}

class SfMessageEvent extends SfEvent<SfMessageEvent>{
  SfMessage? message;
  bool isNew;
  SfMessageEvent({this.message,this.isNew=false});
}
class SfMessageClearEvent extends SfEvent<SfMessageClearEvent>{
  String? convId;
  SfMessageClearEvent({this.convId});
}