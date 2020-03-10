import 'package:bot_toast/bot_toast.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/states/app_state.dart';
import 'package:social_foundation_example/states/user_state.dart';

import 'services/provider_manager.dart';
import 'config.dart';
import 'services/chat_manager.dart';
import 'services/router_manager.dart';
import 'services/storage_manager.dart';
import 'states/chat_state.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: RefreshConfiguration(
        shouldFooterFollowWhenNotFull: (status) => false,
        child: BotToastInit(
          child: MaterialApp(
            title: 'social foundation',
            localizationsDelegates: [
              RefreshLocalizations.delegate
            ],
            navigatorObservers: [RouterManager.instance,BotToastNavigatorObserver()],
            onGenerateRoute: RouterManager.instance.generateRoute,
            initialRoute: RouteName.Signin,
          ),
        )
      )
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureServices();
  await configure();
  runApp(App());
}

void configureServices(){
  GetIt.instance.registerSingleton(EventBus());
  GetIt.instance.registerSingleton<SfStorageManager>(StorageManager());
  GetIt.instance.registerSingleton<SfRouterManager>(RouterManager());
  GetIt.instance.registerSingleton(AppState());
  GetIt.instance.registerSingleton<SfUserState>(UserState());
  GetIt.instance.registerSingleton<SfChatState>(ChatState());
  GetIt.instance.registerSingleton<SfChatManager>(ChatManager(LeancloudSecret.appId, LeancloudSecret.appKey, LeancloudSecret.serverURL));
}

Future<void> configure() async {
  SfAliyunOss.initialize(AliyunSecret.accountId,AliyunSecret.accessKeyId,AliyunSecret.accessKeySecret,AliyunSecret.region,AliyunSecret.bucket);
}