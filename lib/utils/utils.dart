import 'package:uuid/uuid.dart';

class Utils{
  static uuid() => Uuid().v4().replaceAll(new RegExp(r'/[-]/g'),'');
}