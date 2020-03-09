import 'dart:async';

import 'package:flutter/services.dart';

//utils
export './utils/utils.dart';
export './utils/file_helper.dart';
export './utils/aliyun_oss.dart';
//models
export './models/message.dart';
export './models/conversation.dart';
export './models/user.dart';
//widgets
export './widgets/view_state.dart';
export './widgets/provider_widget.dart';
export './widgets/page_route.dart';
export './widgets/photo_viewer.dart';
export './widgets/avatar.dart';
export './widgets/audio_widget.dart';
export './widgets/badge.dart';
export './widgets/cached_image_provider.dart';
//viewmodels
export './view_models/audio_model.dart';
//services
export './services/storage_manager.dart';
export './services/chat_manager.dart';
export './services/event_manager.dart';
//states
export './states/chat_state.dart';
export './states/user_state.dart';

class SocialFoundation {
  static final SocialFoundation instance = new SocialFoundation();
  static const MethodChannel _channel = const MethodChannel('social_foundation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
