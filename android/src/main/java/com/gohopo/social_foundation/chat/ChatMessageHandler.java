package com.gohopo.social_foundation.chat;

import com.gohopo.social_foundation.chat.leancloud.MessageHandler;

import cn.leancloud.im.v2.AVIMMessageManager;
import cn.leancloud.im.v2.AVIMTypedMessage;
import io.flutter.plugin.common.EventChannel;

public class ChatMessageHandler implements EventChannel.StreamHandler {
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        MessageHandler.getInstance().setFlutterEvents(events);
        AVIMMessageManager.registerMessageHandler(AVIMTypedMessage.class, MessageHandler.getInstance());
    }
    @Override
    public void onCancel(Object arguments) {
        MessageHandler.getInstance().setFlutterEvents(null);
        AVIMMessageManager.unregisterMessageHandler(AVIMTypedMessage.class, MessageHandler.getInstance());
    }
}
