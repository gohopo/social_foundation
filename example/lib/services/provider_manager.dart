import 'package:provider/single_child_widget.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/states/app_state.dart';
import 'package:social_foundation_example/states/chat_state.dart';
import 'package:social_foundation_example/states/user_state.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<AppState>(
    create: (_) => GetIt.instance<AppState>(),
  ),
  ChangeNotifierProvider<UserState>(
    create: (_) => GetIt.instance<SfUserState>(),
  ),
  ChangeNotifierProvider<ChatState>(
    create: (_) => GetIt.instance<SfChatState>(),
  )
];