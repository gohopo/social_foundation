import 'dart:async';

import 'package:flutter/services.dart';

export 'package:bot_toast/bot_toast.dart';
export 'package:common_utils/common_utils.dart';
export 'package:event_bus/event_bus.dart';
export 'package:extended_image/extended_image.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:fluwx/fluwx.dart';
export 'package:get_it/get_it.dart';
export 'package:image_picker/image_picker.dart';
export 'package:provider/provider.dart';
export 'package:pull_to_refresh/pull_to_refresh.dart';
export 'package:shimmer/shimmer.dart';
//utils
export './utils/utils.dart';
export './utils/file_helper.dart';
export './utils/aliyun_oss.dart';
export './utils/date_helper.dart';
export './utils/image_helper.dart';
export './utils/wechat_helper.dart';
//models
export './models/app.dart';
export './models/message.dart';
export './models/conversation.dart';
export './models/user.dart';
//widgets
export './widgets/view_state.dart';
export './widgets/provider_widget.dart';
export './widgets/page_route.dart';
export './widgets/avatar.dart';
export './widgets/audio_widget.dart';
export './widgets/badge.dart';
export './widgets/cached_image_provider.dart';
export './widgets/user_widget.dart';
export './widgets/image_picker.dart';
export './widgets/keep_alive.dart';
export './widgets/rolling_number.dart';
export './widgets/toast.dart';
export './widgets/ticker_provider.dart';
export './widgets/skeleton.dart';
//pages
export './pages/photo_viewer.dart';
//viewmodels
export './view_models/audio_model.dart';
export './view_models/chat_model.dart';
//services
export './services/storage_manager.dart';
export './services/chat_manager.dart';
export './services/event_manager.dart';
export './services/router_manager.dart';
export './services/request_manager.dart';
//states
export './states/app_state.dart';
export './states/chat_state.dart';
export './states/user_state.dart';

class SocialFoundation {
  static final SocialFoundation instance = new SocialFoundation();
  static const MethodChannel _channel = const MethodChannel('social_foundation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static void initialize(String appId, String appKey, String serverURL){
    _channel.invokeMethod('initialize', {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
  }
}
