import 'dart:async';

import 'package:flutter/services.dart';

export 'package:audioplayers/audioplayers.dart';
export 'package:bot_toast/bot_toast.dart';
export 'package:collection/collection.dart';
export 'package:common_utils/common_utils.dart';
export 'package:device_info_plus/device_info_plus.dart';
export 'package:dio/dio.dart';
export 'package:event_bus/event_bus.dart';
export 'package:extended_image/extended_image.dart' hide MultipartFile;
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_sound/flutter_sound.dart' hide PlayerState;
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:fluwx/fluwx.dart';
export 'package:get_it/get_it.dart';
export 'package:image_gallery_saver/image_gallery_saver.dart';
export 'package:image_picker/image_picker.dart';
export 'package:leancloud_official_plugin/leancloud_plugin.dart' hide Client,Conversation,Message;
export 'package:path_provider/path_provider.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:provider/provider.dart';
export 'package:pull_to_refresh/pull_to_refresh.dart';
export 'package:shimmer/shimmer.dart';
export 'package:sqflite/sqflite.dart';
export 'package:svgaplayer_flutter/svgaplayer_flutter.dart';
//utils
export './utils/list.dart';
export './utils/utils.dart';
export './utils/file_helper.dart';
export './utils/aliyun_oss.dart';
export './utils/date_helper.dart';
export './utils/image_helper.dart';
export './utils/wechat_helper.dart';
export './utils/contracts.dart';
export './utils/extensions.dart';
//models
export './models/app.dart';
export './models/message.dart';
export './models/conversation.dart';
export './models/user.dart';
export './models/theme.dart';
export './models/entity.dart';
//widgets
export './widgets/view_state.dart';
export './widgets/provider_widget.dart';
export './widgets/page_route.dart';
export './widgets/avatar.dart';
export './widgets/audio_widget.dart';
export './widgets/badge.dart';
export './widgets/cached_image_provider.dart';
export './widgets/user_widget.dart';
export './widgets/chat_input.dart';
export './widgets/keep_alive.dart';
export './widgets/rolling_number.dart';
export './widgets/toast.dart';
export './widgets/ticker_provider.dart';
export './widgets/skeleton.dart';
export './widgets/animation.dart';
export './widgets/nine_patch_image.dart';
export './widgets/bottom_navigation_bar_item.dart';
export './widgets/path.dart';
export './widgets/paint.dart';
export './widgets/text.dart';
export './widgets/sliver.dart';
export './widgets/color_filtered.dart';
//pages
export './pages/photo_viewer.dart';
//viewmodels
export './view_models/chat_model.dart';
export './view_models/list_model.dart';
//services
export './services/storage_manager.dart';
export './services/chat_manager.dart';
export './services/event_manager.dart';
export './services/router_manager.dart';
export './services/request_manager.dart';
export './services/locator_manager.dart';
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
  static Future openMainActivity(){
    return _channel.invokeMethod('openMainActivity');
  }
}
