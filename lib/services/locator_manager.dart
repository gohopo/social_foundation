import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/chat_manager.dart';
import 'package:social_foundation/services/request_manager.dart';
import 'package:social_foundation/services/router_manager.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/states/app_state.dart';
import 'package:social_foundation/states/chat_state.dart';
import 'package:social_foundation/states/user_state.dart';

class SfLocatorManager{
  static SfChatManager get chatManager => GetIt.instance.get<SfChatManager>();
  static SfRequestManager get requestManager => GetIt.instance.get<SfRequestManager>();
  static SfRouterManager get routerManager => GetIt.instance.get<SfRouterManager>();
  static SfStorageManager get storageManager => GetIt.instance.get<SfStorageManager>();
  static SfAppState get appState => GetIt.instance.get<SfAppState>();
  static SfChatState get chatState => GetIt.instance.get<SfChatState>();
  static SfUserState get userState => GetIt.instance.get<SfUserState>();
}