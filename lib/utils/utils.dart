import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class SfUtils{
  static String uuid() => Uuid().v4().replaceAll(new RegExp(r'[-]'),'');
  static Uint8List encrypt(Uint8List bytes){
    for(var i=0;i<bytes.length;++i){
      bytes[i] = 255 - bytes[i];
    }
    return bytes;
  }
  static String base64(String data) => base64ByList(convert.utf8.encode(data));
  static String base64ByList(List<int> data) => convert.base64.encode(data);
  static String md5(String data) => crypto.md5.convert(convert.utf8.encode(data)).toString();
  static String sha256(String data) => crypto.sha256.convert(convert.utf8.encode(data)).toString();
  static String hmacSha1(String key,String data) => hmacSha1Digest(key,data).toString();
  static crypto.Digest hmacSha1Digest(String key,String data){
    var hmac = crypto.Hmac(crypto.sha1,convert.utf8.encode(key));
    return hmac.convert(convert.utf8.encode(data));
  }
  static String hmacSha256(String key,String data){
    var hmac = crypto.Hmac(crypto.sha256,convert.utf8.encode(key));
    return hmac.convert(convert.utf8.encode(data)).toString();
  }
  static int getIndexInRange<T>(List<T> range,bool predicate(T element)){
    var index = range.indexWhere(predicate);
    if(--index < 0) index = range.length-1;
    return index;
  }
  static int calcIndexInRange(int value,int calculator(int index)){
    var index = 0;
    for(;value >= calculator(index);++index){}
    return index;
  }
  //获取经验等级
  static int getLevelFromExp(List<int> exps,int exp) => getIndexInRange<int>(exps,(e) => e>exp);
  static int calcLevelFromExp(int exp,int calculator(int level)) => calcIndexInRange(exp,calculator);
  //返回min,max之间的随机数
  static int randRange(int min,int max) => min + Random().nextInt(max-min);
  static double randRangeDouble(double min,double max) => min + Random().nextDouble()*(max-min);
  //数组中随机选取
  static List<T> randomArrayChoose<T>(List<T> list,int num){
    list.shuffle();
    return list.sublist(0,num);
  }
  //数组中随机选取一个
  static T randomArrayChooseOne<T>(List<T> list) => randomArrayChoose(list,1)[0];
  //概率(概率小的排在前面)
  static int randomProbability(List<int> probabilities){
    int sum = probabilities.reduce((sum,prob) => sum+prob);
    int index = -1;
    for(int i=0;i<probabilities.length;++i){
      if(Random().nextInt(sum) <= probabilities[i]){
        index = i;
        break;
      }
      sum -= probabilities[i];
    }
    return index;
  }
  static List<T> distinct<T,TKey>(List<T> source,TKey Function(T data)? keySelector){
    keySelector ??= (T v) => v as TKey;
    List<T> list = [];
    var sets = <TKey>{};
    for (var data in source) {
      if (sets.add(keySelector(data))){
        list.add(data);
      }
    }
    return list;
  }
  static Future<Map> getDeviceInfo() async {
    var result = {};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isIOS){
      var info = await deviceInfo.iosInfo;
      result['device'] = '${info.model}${info.systemVersion}';
      result['deviceId'] = info.identifierForVendor;
    }
    else{
      var info = await deviceInfo.androidInfo;
      result['device'] = '${info.manufacturer}${info.model}';
      result['deviceId'] = info.androidId;
    }
    return result;
  }
  static Future<String> getDeviceId() async {
    var result = await getDeviceInfo();
    return result['deviceId'];
  }
  static Future<String?> getClientIp() => getClientIpEnhanced();
  static Future<String?> getClientIpEnhanced({List<String>? apiList,String Function(dynamic)? converter,int timeout=2000}) async {
    apiList = apiList ?? [
      'http://www.trackip.net/ip','http://icanhazip.com/','https://www.fbisb.com/ip.php'
    ];
    var dio = Dio(BaseOptions(sendTimeout:timeout,receiveTimeout:timeout));
    for(var api in apiList){
      try{
        var response = await dio.get(api);
        return converter?.call(response.data) ?? response.data;
      }
      catch(error){

      }
    }
    return null;
  }
  //填充字符串
  static String padValue(int value,{bool pad=true,int width=2,String padding='0'}) => pad ? value.toString().padLeft(width,padding) : value.toString();
}