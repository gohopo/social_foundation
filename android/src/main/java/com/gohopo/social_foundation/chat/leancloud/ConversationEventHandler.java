package com.gohopo.social_foundation.chat.leancloud;

import com.gohopo.social_foundation.chat.ChatEventHandler;
import com.gohopo.social_foundation.chat.utils.Constants;

import java.util.List;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMConversationEventHandler;
import cn.leancloud.im.v2.AVIMMessage;

public class ConversationEventHandler extends AVIMConversationEventHandler {
    @Override
    public void onUnreadMessagesCountUpdated(AVIMClient client, AVIMConversation conversation) {
        ChatEventHandler.getInstance().emit(Constants.Event_onUnreadMessagesCountUpdated,conversation,null);
    }
    @Override
    public void onLastDeliveredAtUpdated(AVIMClient client, AVIMConversation conversation) {
        ChatEventHandler.getInstance().emit(Constants.Event_onLastDeliveredAtUpdated,conversation,null);
    }
    @Override
    public void onLastReadAtUpdated(AVIMClient client, AVIMConversation conversation) {
        ChatEventHandler.getInstance().emit(Constants.Event_onLastReadAtUpdated,conversation,null);
    }
    @Override
    public void onMessageRecalled(AVIMClient client, AVIMConversation conversation, AVIMMessage message) {
        ChatEventHandler.getInstance().emit(Constants.Event_onMessageRecalled,conversation,message);
    }
    @Override
    public void onMessageUpdated(AVIMClient client, AVIMConversation conversation, AVIMMessage message) {
        ChatEventHandler.getInstance().emit(Constants.Event_onMessageUpdated, conversation, message);
    }
    @Override
    public void onMemberLeft(AVIMClient client, AVIMConversation conversation, List<String> members, String kickedBy) {

    }
    @Override
    public void onMemberJoined(AVIMClient client, AVIMConversation conversation, List<String> members, String invitedBy) {

    }
    @Override
    public void onKicked(AVIMClient client, AVIMConversation conversation, String kickedBy) {

    }
    @Override
    public void onInvited(AVIMClient client, AVIMConversation conversation, String operator) {

    }
}
