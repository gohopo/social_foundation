package com.gohopo.social_foundation;

import cn.leancloud.AVLogger;
import cn.leancloud.AVOSCloud;
import cn.leancloud.im.AVIMOptions;

public class SfFunction {
    public static String getPlatformVersion(){
        return android.os.Build.VERSION.RELEASE;
    }
    public static void initialize(String appId,String appKey,String serverURL){
        AVOSCloud.setLogLevel(AVLogger.Level.DEBUG);
        AVOSCloud.initialize(SocialFoundationPlugin.Activity.getApplication(), appId, appKey, serverURL);
        AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
    }
}
