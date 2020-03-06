package com.gohopo.social_foundation.chat;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.chat.utils.Constants;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMClientEventHandler;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMConversationEventHandler;
import cn.leancloud.im.v2.AVIMMessage;
import cn.leancloud.im.v2.AVIMTypedMessage;
import cn.leancloud.im.v2.AVIMTypedMessageHandler;
import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;

public class ChatEventHandler implements EventChannel.StreamHandler {
    public static ChatEventHandler _instance;
    private EventChannel.EventSink _events;

    private ChatEventHandler(){}
    public static synchronized ChatEventHandler getInstance(){
        if(_instance == null){
            _instance = new ChatEventHandler();
        }
        return _instance;
    }
    public void emit(String event, AVIMConversation conversation, AVIMMessage message) {
        Map<String, String> result = new HashMap<>();
        result.put("event", event);
        if (null != conversation) result.put("conversation", JSON.toJSONString(conversation));
        if (null != message) result.put("message", JSON.toJSONString(message));
        if (null != _events) _events.success(result);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        _events = events;
    }
    @Override
    public void onCancel(Object arguments) {
        _events = null;
    }
}
