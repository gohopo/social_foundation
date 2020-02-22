import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation_example/state/app_state.dart';
import 'package:social_foundation_example/state/user_state.dart';

import 'service/provider_manager.dart';
import 'config.dart';
import 'service/chat_manager.dart';
import 'service/router_manager.dart';
import 'service/storage_manager.dart';
import 'state/chat_state.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'social foundation',
        onGenerateRoute: Router.generateRoute,
        initialRoute: RouteName.Login,
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