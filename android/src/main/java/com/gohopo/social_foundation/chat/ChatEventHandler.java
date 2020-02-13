package com.gohopo.social_foundation.chat;

import com.gohopo.social_foundation.chat.leancloud.ClientEventHandler;
import com.gohopo.social_foundation.chat.leancloud.ConversationEventHandler;

import io.flutter.plugin.common.EventChannel;

public class ChatEventHandler implements EventChannel.StreamHandler {
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        ConversationEventHandler.getInstance().setFlutterEvents(events);
        ClientEventHandler.getInstance().setFlutterEvents(events);
    }
    @Override
    public void onCancel(Object arguments) {
        ConversationEventHandler.getInstance().setFlutterEvents(null);
        ClientEventHandler.getInstance().setFlutterEvents(null);
    }
}
