import 'package:flutter/material.dart';
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
      child: Consumer<AppState>(
        builder: (context,appState,child) => RefreshConfiguration(
          shouldFooterFollowWhenNotFull: (status) => false,
          child: MaterialApp(
            title: 'social foundation',
            theme: appState.themeData(ThemeData.light()),
            localizationsDelegates: [
              RefreshLocalizations.delegate
            ],
            navigatorObservers: [RouterManager.instance,BotToastNavigatorObserver()],
            onGenerateRoute: RouterManager.instance.generateRoute,
            initialRoute: RouteName.Signin,
            builder: BotToastInit(),
          )
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
  GetIt.instance.registerSingleton<SfChatManager>(ChatManager());
  GetIt.instance.registerSingleton<SfAppState>(AppState());
  GetIt.instance.registerSingleton<SfChatState>(ChatState());
  GetIt.instance.registerSingleton<SfUserState>(UserState());
}

Future configure() async {
  SfAliyunOss.initialize('https://${AliyunSecret.bucket}.oss-${AliyunSecret.region}.aliyuncs.com',AliyunSecret.accessKeyId,AliyunSecret.accessKeySecret);
  
  await SfLocatorManager.storageManager.init();
  await SfLocatorManager.appState.initData();
}