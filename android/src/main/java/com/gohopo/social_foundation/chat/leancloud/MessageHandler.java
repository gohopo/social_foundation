package com.gohopo.social_foundation.chat.leancloud;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.chat.utils.Constants;

import java.util.HashMap;
import java.util.Map;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMTypedMessage;
import cn.leancloud.im.v2.AVIMTypedMessageHandler;
import io.flutter.plugin.common.EventChannel;

public class MessageHandler extends AVIMTypedMessageHandler<AVIMTypedMessage> {
    private static MessageHandler _instance;
    private EventChannel.EventSink events;

    public static synchronized MessageHandler getInstance() {
        if (null == _instance) {
            _instance = new MessageHandler();
        }
        return _instance;
    }
    public void setFlutterEvents(EventChannel.EventSink events) {
        this.events = events;
    }

    @Override
    public void onMessage(AVIMTypedMessage message, AVIMConversation conversation, AVIMClient client) {
        super.onMessage(message, conversation, client);
        Map<String, String> result = new HashMap<>();
        result.put("event", Constants.Event_onMessageReceived);
        result.put("conversation", JSON.toJSONString(conversation));
        result.put("message", JSON.toJSONString(message));
        if (null != events) events.success(result);
    }
}
