import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
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
  //获取经验等级
  static int getLevelForExp(List<int> exps,int exp){
    var level = exps.indexWhere((e) => e>exp);
    if(--level < 0) level = exps.length-1;
    return level;
  }
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
  static List<T> distinct<T,TKey>(List<T> source,TKey keySelector(T data)){
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
  static Future<String> getClientIp() => getClientIpEnhanced();
  static Future<String> getClientIpEnhanced({List<String> apiList,String converter(data),int timeout=2000}) async {
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
}