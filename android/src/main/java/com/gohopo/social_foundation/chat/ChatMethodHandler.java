package com.gohopo.social_foundation.chat;

import com.alibaba.fastjson.JSON;
import com.gohopo.social_foundation.chat.leancloud.LeancloudFunction;
import com.gohopo.social_foundation.chat.utils.Constants;

import java.util.List;
import java.util.Map;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMConversation;
import cn.leancloud.im.v2.AVIMException;
import cn.leancloud.im.v2.callback.AVIMClientCallback;
import cn.leancloud.im.v2.callback.AVIMConversationCallback;
import cn.leancloud.im.v2.callback.AVIMConversationCreatedCallback;
import cn.leancloud.im.v2.callback.AVIMOperationFailure;
import cn.leancloud.im.v2.callback.AVIMOperationPartiallySucceededCallback;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChatMethodHandler implements MethodChannel.MethodCallHandler {
    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        switch (call.method){
            case Constants.Method_initialize:{
                String appId = call.argument("appId");
                String appKey = call.argument("appKey");
                String serverURL = call.argument("serverURL");
                LeancloudFunction.initialize(appId,appKey,serverURL);
                break;
            }
            case Constants.Method_login:{
                final String userId = call.argument("userId");
                LeancloudFunction.login(userId, new AVIMClientCallback() {
                    @Override
                    public void done(AVIMClient client, AVIMException e) {
                        if(null != e){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success(userId);
                        }
                    }
                });
                break;
            }
            case Constants.Method_close:{
                LeancloudFunction.close(new AVIMClientCallback() {
                    @Override
                    public void done(AVIMClient client, AVIMException e) {
                        if(null != e){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success("");
                        }
                    }
                });
                break;
            }
            case Constants.Method_sendMessage:{
                final String conversationId = call.argument("conversationId");
                final String message = call.argument("message");
                LeancloudFunction.sendMessage(conversationId, message, result);
                break;
            }
            case Constants.Method_convCreate:{
                final String name = call.argument("name");
                final List<String> members = call.argument("members");
                final boolean isUnique = call.argument("isUnique");
                final Map attributes = call.argument("attributes");
                final boolean isTransient = call.argument("isTransient");
                LeancloudFunction.convCreate(name, members, isUnique, attributes, isTransient, new AVIMConversationCreatedCallback() {
                    @Override
                    public void done(AVIMConversation conversation, AVIMException e) {
                        if(e != null){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success(JSON.toJSONString(conversation));
                        }
                    }
                });
                break;
            }
            case Constants.Method_convJoin:{
                String conversationId = call.argument("conversationId");
                LeancloudFunction.convJoin(conversationId, new AVIMConversationCallback() {
                    @Override
                    public void done(AVIMException e) {
                        if(e != null){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success("");
                        }
                    }
                });
                break;
            }
            case Constants.Method_convQuit:{
                String conversationId = call.argument("conversationId");
                LeancloudFunction.convQuit(conversationId,new AVIMConversationCallback() {
                    @Override
                    public void done(AVIMException e) {
                        if(e != null){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success("");
                        }
                    }
                });
                break;
            }
            case Constants.Method_convInvite:{
                String conversationId = call.argument("conversationId");
                List<String> members = call.argument("members");
                LeancloudFunction.convInvite(conversationId,members,new AVIMOperationPartiallySucceededCallback() {
                    @Override
                    public void done(AVIMException e, List<String> successfulClientIds, List<AVIMOperationFailure> failures) {
                        if(e != null){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success("");
                        }
                    }
                });
                break;
            }
            case Constants.Method_convKick:{
                String conversationId = call.argument("conversationId");
                List<String> members = call.argument("members");
                LeancloudFunction.convKick(conversationId,members,new AVIMOperationPartiallySucceededCallback() {
                    @Override
                    public void done(AVIMException e, List<String> successfulClientIds, List<AVIMOperationFailure> failures) {
                        if(e != null){
                            result.error("",e.getMessage(),null);
                        }
                        else{
                            result.success("");
                        }
                    }
                });
                break;
            }
            case Constants.Method_convRead:{
                String conversationId = call.argument("conversationId");
                LeancloudFunction.convRead(conversationId);
                break;
            }
            default:{
                result.notImplemented();
                break;
            }
        }
    }
}
