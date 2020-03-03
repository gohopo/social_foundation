import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:social_foundation/utils/file_helper.dart';

class SfAliyunOss {
  static String accessKeyId;
  static String endPoint;
  static String policy;
  static String signature;
  static initialize(int accountId,String _accessKeyId,String accessKeySecret,String region,String bucket){
    accessKeyId = _accessKeyId;
    endPoint = '$bucket.oss-$region.aliyuncs.com';
    String policyText = '{"expiration": "2222-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';
    policy = base64.encode(utf8.encode(policyText));
    signature = base64.encode(Hmac(sha1,utf8.encode(accessKeySecret)).convert(utf8.encode(policy)).bytes);
  }
  static Future<Response> uploadFile({String dir,File file,ProgressCallback onSendProgress}) async {
    var fileName = SfFileHelper.getFileName(file.path);
    FormData data = FormData.fromMap({
      'Filename': fileName,
      'key': '$dir/$fileName',
      'policy': policy,
      'OSSAccessKeyId': accessKeyId,
      'success_action_status': '200',
      'signature': signature,
      'file': await MultipartFile.fromFile(file.path,filename: fileName)
    });
    Dio dio = Dio(BaseOptions(responseType: ResponseType.plain));
    return dio.post(endPoint,data: data,onSendProgress:onSendProgress);
  }
}