import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_foundation_example/states/chat_state.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<ChatState>(
    create: (_) => GetIt.instance<ChatState>(),
  )
];