package com.gohopo.social_foundation.chat.leancloud;

import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.SocialFoundationPlugin;

import java.util.List;
import java.util.Map;

import cn.leancloud.AVInstallation;
import cn.leancloud.AVLogger;
import cn.leancloud.AVOSCloud;
import cn.leancloud.im.AVIMOptions;
import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMException;
import cn.leancloud.im.v2.AVIMMessage;
import cn.leancloud.im.v2.AVIMMessageManager;
import cn.leancloud.im.v2.AVIMMessageOption;
import cn.leancloud.im.v2.AVIMTypedMessage;
import cn.leancloud.im.v2.callback.AVIMClientCallback;
import cn.leancloud.im.v2.callback.AVIMConversationCallback;
import cn.leancloud.im.v2.callback.AVIMConversationCreatedCallback;
import cn.leancloud.im.v2.callback.AVIMMessagesQueryCallback;
import cn.leancloud.im.v2.callback.AVIMOperationPartiallySucceededCallback;
import cn.leancloud.im.v2.messages.AVIMTextMessage;
import io.flutter.plugin.common.MethodChannel;

public class LeancloudFunction {
    private static boolean isInitialized = false;
    private static String curUserId;
    public static void initialize(String appId,String appKey,String serverURL){
        if(isInitialized) return;
        isInitialized = true;
        AVOSCloud.initialize(SocialFoundationPlugin.Activity.getApplication(), appId, appKey, serverURL);
        //AVOSCloud.setLogLevel(AVLogger.Level.DEBUG);
        AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
        AVIMClient.setClientEventHandler(new ClientEventHandler());
        AVIMMessageManager.setConversationEventHandler(new ConversationEventHandler());
        AVIMMessageManager.registerMessageHandler(AVIMTypedMessage.class,new MessageHandler());
        AVInstallation.getCurrentInstallation().saveInBackground();
    }
    public static AVIMClient getClient(){
        if(!TextUtils.isEmpty(curUserId)){
            return AVIMClient.getInstance(curUserId);
        }
        return null;
    }
    public static void login(final String userId, final AVIMClientCallback callback){
        AVIMClient.getInstance(userId).open(new AVIMClientCallback() {
            @Override
            public void done(AVIMClient client, AVIMException e) {
                if(null == e){
                    curUserId = userId; 
                }
                callback.internalDone(client,e);
            }
        });
    }
    public static void close(final AVIMClientCallback callback){
        AVIMClient.getInstance(curUserId).close(new AVIMClientCallback() {
            @Override
            public void done(AVIMClient client, AVIMException e) {
                curUserId = null;
                callback.internalDone(client,e);
            }
        });
    }
    public static AVIMConversation getConversation(String conversationId){
        return getClient().getConversation(conversationId);
    }
    public static void sendMessage(String conversationId, String message, final MethodChannel.Result result){
        AVIMConversation conversation = getConversation(conversationId);
        final AVIMTextMessage msg = new AVIMTextMessage();
        msg.setText(message);
        AVIMMessageOption option = new AVIMMessageOption();
        option.setReceipt(true);
        conversation.sendMessage(msg, option, new AVIMConversationCallback() {
            @Override
            public void done(AVIMException e) {
                if(null != e){
                    result.error("",e.getMessage(),null);
                }
                else{
                    result.success(JSON.parse(JSON.toJSONString(msg)));
                }
            }
        });
    }
    public static void queryMessages(final AVIMConversation conversation, String msgId, long timestamp, final int limit, final List<AVIMMessage> result, final AVIMMessagesQueryCallback callback){
        conversation.queryMessages(msgId, timestamp, Math.min(limit, 1000), new AVIMMessagesQueryCallback() {
            @Override
            public void done(List<AVIMMessage> messages, AVIMException e) {
                if(e != null){
                    callback.internalDone(result,e);
                }
                else{
                    result.addAll(0,messages);
                    if(result.size()==limit || messages.size()<1000){
                        callback.internalDone(result,e);
                    }
                    else{
                        AVIMMessage message = messages.get(0);
                        queryMessages(conversation,message.getMessageId(),message.getTimestamp(),limit-1000,result,callback);
                    }
                }
            }
        });
    }
    public static void convCreate(String name, List<String> members, boolean isUnique, Map<String, Object> attributes, boolean isTransient, AVIMConversationCreatedCallback callback){
        getClient().createConversation(members,name,attributes,isTransient,isUnique,callback);
    }
    public static void convJoin(String conversationId,AVIMConversationCallback callback){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.join(callback);
    }
    public static void convQuit(String conversationId,AVIMConversationCallback callback){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.quit(callback);
    }
    public static void convInvite(String conversationId,List<String> members,AVIMOperationPartiallySucceededCallback callback){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.addMembers(members,callback);
    }
    public static void convKick(String conversationId, List<String> members, AVIMOperationPartiallySucceededCallback callback){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.kickMembers(members,callback);
    }
    public static void convRead(String conversationId){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.read();
    }
}
