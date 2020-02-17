package com.gohopo.social_foundation.chat.leancloud;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.chat.ChatEventHandler;
import com.gohopo.social_foundation.chat.utils.Constants;

import java.util.HashMap;
import java.util.Map;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMTypedMessage;
import cn.leancloud.im.v2.AVIMTypedMessageHandler;

public class MessageHandler extends AVIMTypedMessageHandler<AVIMTypedMessage> {
    @Override
    public void onMessage(AVIMTypedMessage message, AVIMConversation conversation, AVIMClient client) {
        super.onMessage(message, conversation, client);
        ChatEventHandler.getInstance().emit(Constants.Event_onMessageReceived,conversation,message);
    }
}
