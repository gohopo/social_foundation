package com.gohopo.social_foundation;

import com.github.gzuliyujiang.oaid.IGetter;

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
            case "getAndroidID":{
                result.success(SfFunction.getAndroidID());
                break;
            }
            case "getOAID":{
                SfFunction.getOAID(new IGetter() {
                    @Override
                    public void onOAIDGetComplete(String oaid) {
                        result.success(oaid);
                    }
                    @Override
                    public void onOAIDGetError(Exception error) {
                        result.success("");
                    }
                });

                break;
            }
            default:{
                result.notImplemented();
                break;
            }
        }
    }
}
