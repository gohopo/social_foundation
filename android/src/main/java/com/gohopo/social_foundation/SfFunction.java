package com.gohopo.social_foundation;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Context;
import android.content.Intent;

public class SfFunction {
    public static String getPlatformVersion(){
        return android.os.Build.VERSION.RELEASE;
    }
    public static void openPackageActivity(String packageName){
        openActivity(SocialFoundationPlugin.context.getPackageManager().getLaunchIntentForPackage(packageName));
    }
    public static void openActivity(Intent intent){
        if(intent==null) return;
        intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        SocialFoundationPlugin.context.startActivity(intent);
    }
    public static void openMainActivity(){
        openPackageActivity(SocialFoundationPlugin.context.getPackageName());
    }
}
