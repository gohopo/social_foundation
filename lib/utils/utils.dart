import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:uuid/uuid.dart';

class SfUtils{
  static uuid() => Uuid().v4().replaceAll(new RegExp(r'[-]'),'');
  static Uint8List encrypt(Uint8List bytes){
    for(var i=0;i<bytes.length;++i){
      bytes[i] = 255 - bytes[i];
    }
    return bytes;
  }
  static String md5(String data){
    return crypto.md5.convert(Utf8Encoder().convert(data)).toString();
  }
}