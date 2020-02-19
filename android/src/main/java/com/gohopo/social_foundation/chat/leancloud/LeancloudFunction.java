package com.gohopo.social_foundation.chat.leancloud;

import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.SocialFoundationPlugin;
import com.gohopo.social_foundation.chat.utils.Constants;

import cn.leancloud.AVLogger;
import cn.leancloud.AVOSCloud;
import cn.leancloud.im.AVIMOptions;
import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMException;
import cn.leancloud.im.v2.AVIMMessageManager;
import cn.leancloud.im.v2.AVIMMessageOption;
import cn.leancloud.im.v2.AVIMTypedMessage;
import cn.leancloud.im.v2.callback.AVIMClientCallback;
import cn.leancloud.im.v2.callback.AVIMConversationCallback;
import cn.leancloud.im.v2.messages.AVIMTextMessage;
import io.flutter.plugin.common.MethodChannel;

public class LeancloudFunction {
    private static String curUserId;
    public static void initialize(String appId,String appKey,String serverURL){
        AVOSCloud.initialize(SocialFoundationPlugin.Activity.getApplication(), appId, appKey, serverURL);
        //AVOSCloud.setLogLevel(AVLogger.Level.DEBUG);
        AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
        AVIMClient.setClientEventHandler(new ClientEventHandler());
        AVIMMessageManager.setConversationEventHandler(new ConversationEventHandler());
        AVIMMessageManager.registerMessageHandler(AVIMTypedMessage.class,new MessageHandler());
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
    public static void setConversationRead(String conversationId){
        AVIMConversation conversation = getConversation(conversationId);
        conversation.read();
    }
}
