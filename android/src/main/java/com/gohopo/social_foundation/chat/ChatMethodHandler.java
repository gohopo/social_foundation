package com.gohopo.social_foundation.chat;

import com.gohopo.social_foundation.chat.leancloud.LeancloudFunction;
import com.gohopo.social_foundation.chat.utils.Constants;
import com.gohopo.social_foundation.utils.SfResponse;

import cn.leancloud.im.v2.AVIMClient;
import cn.leancloud.im.v2.AVIMException;
import cn.leancloud.im.v2.callback.AVIMClientCallback;
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
                            SfResponse.returnError(result,Constants.Code_error,e.getMessage());
                        }
                        else{
                            SfResponse.returnResult(result,userId);
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
                            SfResponse.returnError(result,Constants.Code_error,e.getMessage());
                        }
                        else{
                            SfResponse.returnResult(result,Constants.Code_success);
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
            case Constants.Method_setConversationRead:{
                String conversationId = call.argument("conversationId");
                int code = LeancloudFunction.setConversationRead(conversationId);
                if(Constants.Code_success == code){
                    SfResponse.returnResult(result,"");
                }
                else{
                    SfResponse.returnError(result,code,"");
                }
                break;
            }
            default:{
                result.notImplemented();
                break;
            }
        }
    }
}
