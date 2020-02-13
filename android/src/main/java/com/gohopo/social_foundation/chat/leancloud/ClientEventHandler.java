package com.gohopo.social_foundation.chat.leancloud;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMClientEventHandler;
import io.flutter.plugin.common.EventChannel;

public class ClientEventHandler extends AVIMClientEventHandler {
    private static ClientEventHandler _instance;
    private EventChannel.EventSink events;

    public static synchronized ClientEventHandler getInstance() {
        if (null == _instance) {
            _instance = new ClientEventHandler();
        }
        return _instance;
    }
    public void setFlutterEvents(EventChannel.EventSink events) {
        this.events = events;
    }

    @Override
    public void onConnectionPaused(AVIMClient client) {

    }
    @Override
    public void onConnectionResume(AVIMClient client) {

    }
    @Override
    public void onClientOffline(AVIMClient client, int code) {

    }
}
