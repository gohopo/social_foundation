package com.gohopo.social_foundation;

import android.app.Activity;
import android.app.Application;

import com.gohopo.social_foundation.chat.ChatEventHandler;
import com.gohopo.social_foundation.chat.ChatMessageHandler;
import com.gohopo.social_foundation.chat.ChatMethodHandler;

import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

/** SocialFoundationPlugin */
public class SocialFoundationPlugin implements FlutterPlugin, ActivityAware {
  public static Activity Activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
      final MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation");
      channel.setMethodCallHandler(new SfMethodHandler());
      //chat
      final MethodChannel chatChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation/chat");
      chatChannel.setMethodCallHandler(new ChatMethodHandler());
      final EventChannel chatMessageChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation/chat/messages");
      chatMessageChannel.setStreamHandler(new ChatMessageHandler());
      final EventChannel chatEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation/chat/events");
      chatEventChannel.setStreamHandler(new ChatEventHandler());
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
