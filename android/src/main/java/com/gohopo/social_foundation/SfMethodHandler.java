package com.gohopo.social_foundation;

import com.gohopo.social_foundation.utils.Constants;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SfMethodHandler implements MethodChannel.MethodCallHandler {
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method){
            case Constants.Method_getPlatformVersion:{
                result.success("Android " +  SfFunction.getPlatformVersion());
                break;
            }
            default:{
                result.notImplemented();
                break;
            }
        }
    }
}
