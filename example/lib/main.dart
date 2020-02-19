import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'config/provider_manager.dart';
import 'config/secrets.dart';
import 'config/chat_manager.dart';
import 'config/router_manager.dart';
import 'config/storage_manager.dart';
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
  GetIt.instance.registerSingleton(ChatState());
  GetIt.instance.registerSingleton(ChatManager(LeancloudSecret.appId, LeancloudSecret.appKey, LeancloudSecret.serverURL));
}

Future<void> configure() async {
  
}