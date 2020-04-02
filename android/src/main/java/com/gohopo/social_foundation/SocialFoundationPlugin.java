package com.gohopo.social_foundation;

import android.app.Activity;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/** SocialFoundationPlugin */
public class SocialFoundationPlugin implements FlutterPlugin, ActivityAware {
  public static Activity Activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
      final MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation");
      channel.setMethodCallHandler(new SfMethodHandler());
  }
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
      Activity = binding.getActivity();
  }
  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }
  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }
  @Override
  public void onDetachedFromActivity() {

  }
}
