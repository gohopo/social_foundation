package com.gohopo.social_foundation;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SfMethodHandler implements MethodChannel.MethodCallHandler {
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method){
            case "getPlatformVersion":{
                result.success("Android " +  SfFunction.getPlatformVersion());
                break;
            }
            case "openMainActivity":{
                SfFunction.openMainActivity();
                break;
            }
            default:{
                result.notImplemented();
                break;
            }
        }
    }
}
