package com.gohopo.social_foundation;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Intent;
import android.text.TextUtils;

import com.github.gzuliyujiang.oaid.DeviceID;
import com.github.gzuliyujiang.oaid.DeviceIdentifier;
import com.github.gzuliyujiang.oaid.IGetter;

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
    public static String getAndroidID(){
        return DeviceIdentifier.getAndroidID(SocialFoundationPlugin.context);
    }
    public static void getOAID(IGetter getter){
        String oaid = DeviceID.getOAID();
        if(TextUtils.isEmpty(oaid)){
            DeviceID.getOAID(SocialFoundationPlugin.activity.getApplication(),getter);
        }
        else{
            getter.onOAIDGetComplete(oaid);
        }
    }
}
