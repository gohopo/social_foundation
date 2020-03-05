import 'dart:typed_data';

import 'package:uuid/uuid.dart';

class SfUtils{
  static uuid() => Uuid().v4().replaceAll(new RegExp(r'/[-]/g'),'');
  static Uint8List encrypt(Uint8List bytes){
    for(var i=0;i<bytes.length;++i){
      bytes[i] = 255 - bytes[i];
    }
    return bytes;
  }
}