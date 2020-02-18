import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/config/provider_manager.dart';
import 'package:social_foundation_example/config/secrets.dart';
import 'package:social_foundation_example/states/chat_state.dart';
import 'config/chat_manager.dart';
import 'config/router_manager.dart';

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
  //ioc
  GetIt.instance.registerSingleton(EventBus());
  GetIt.instance.registerSingleton(ChatState());

  //chat
  ChatService.initialize(LeancloudSecret.appId, LeancloudSecret.appKey, LeancloudSecret.serverURL,new ChatManager());
}

Future<void> configure() async {
  
}