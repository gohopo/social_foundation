package com.gohopo.social_foundation.utils;

import java.util.HashMap;
import java.util.Map;

import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

public class SfResponse {
    public static void returnResult(MethodChannel.Result result, Object data){
        Map<String, Object> dict = new HashMap<>();
        dict.put("code", 0);
        dict.put("result", data);
        result.success(dict);
    }
    public static void returnError(MethodChannel.Result result, int code, @Nullable String message){
        Map<String, Object> dict = new HashMap<>();
        dict.put("code", code);
        dict.put("message", message!=null ? message : "");
        result.success(dict);
    }
}
