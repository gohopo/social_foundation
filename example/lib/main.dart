import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
        child: MaterialApp(
          title: 'social foundation',
          localizationsDelegates: [
            RefreshLocalizations.delegate
          ],
          onGenerateRoute: Router.generateRoute,
          initialRoute: RouteName.Login,
        ),
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
  GetIt.instance.registerSingleton(StorageManager());
  GetIt.instance.registerSingleton(EventBus());
  GetIt.instance.registerSingleton(AppState());
  GetIt.instance.registerSingleton(UserState());
  GetIt.instance.registerSingleton(ChatState());
  GetIt.instance.registerSingleton(ChatManager(LeancloudSecret.appId, LeancloudSecret.appKey, LeancloudSecret.serverURL));
}

Future<void> configure() async {
  
}