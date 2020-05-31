import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/utils/file_helper.dart';
import 'package:social_foundation/utils/utils.dart';

class SfAliyunOss {
  static String accessKeyId;
  static String endPoint;
  static String policy;
  static String signature;
  static void initialize(int accountId,String _accessKeyId,String accessKeySecret,String region,String bucket){
    accessKeyId = _accessKeyId;
    endPoint = 'https://$bucket.oss-$region.aliyuncs.com';
    String policyText = '{"expiration": "2222-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';
    policy = base64.encode(utf8.encode(policyText));
    signature = base64.encode(Hmac(sha1,utf8.encode(accessKeySecret)).convert(utf8.encode(policy)).bytes);
  }
  static String generateFileKey(String filePath,{String prefix='',int encrypt=0}){
    return generateFileKeyWithExt(SfFileHelper.getFileExt(filePath),prefix:prefix,encrypt:encrypt);
  }
  static String generateFileKeyWithExt(String fileExt,{String prefix='',int encrypt=0}){
    var fileKey = '${SfUtils.uuid()}_$encrypt';
    if(prefix.isNotEmpty) fileKey = '${prefix}_$fileKey';
    return fileKey += fileExt;
  }
  static Future<String> cacheFile(String dir,String srcFilePath,{String prefix='',int encrypt=0}) async {
    var fileKey = generateFileKey(srcFilePath,prefix:prefix,encrypt:encrypt);
    var filePath = getFilePath(dir,fileKey);
    await File(srcFilePath).copy(filePath);
    return filePath;
  }
  static int isEncryptFile(String path) => isEncryptFileName(SfFileHelper.getFileNameWithoutExt(path));
  static int isEncryptFileUrl(String url) => isEncryptFileName(SfFileHelper.getUrlNameWithoutExt(url));
  static int isEncryptFileName(String name){
    name = SfFileHelper.getFileNameWithoutExt(name);
    var index = name.lastIndexOf('_');
    if(index != -1){
      var encrypt = name.substring(index+1,name.length);
      return int.parse(encrypt);
    }
    return 0;
  }
  static String getFilePath(String dir,String fileKey) => p.join(GetIt.instance<SfStorageManager>().getFileDirectory(dir),fileKey);
  static Future<Response> uploadImage(String filePath,{String fileName,ProgressCallback onSendProgress}){
    return uploadFile(SfMessageType.image,filePath,fileName:fileName,onSendProgress: onSendProgress);
  }
  static Future<Response> uploadVoice(String filePath,{String fileName,ProgressCallback onSendProgress}){
    return uploadFile(SfMessageType.voice,filePath,fileName:fileName,onSendProgress: onSendProgress);
  }
  static String getImageUrl(String fileKey,{String mode,int width,int height,int short,int long,int limit,int percent}){
    String url = getFileUrl('image',fileKey);
    String resize = '';
    if(mode != null) resize += ',m_$mode';
    if(width != null) resize += ',w_$width';
    if(height != null) resize += ',h_$height';
    if(short != null) resize += ',s_$short';
    if(long != null) resize += ',l_$long';
    if(limit != null) resize += ',limit_$limit';
    if(percent != null) resize += ',p_$percent';
    if(resize.isNotEmpty) url += '?x-oss-process=image/resize' + resize;
    return url;
  }
  static String getFileUrl(String dir,String fileKey){
    if(isEncryptFileName(fileKey) > 0) dir = 'Encrypt' + dir;
    return '$endPoint/$dir/$fileKey';
  }
  static Future<Response> uploadFile(String dir,String filePath,{String fileName,ProgressCallback onSendProgress}) async {
    fileName = fileName ?? SfFileHelper.getFileName(filePath);
    var bytes = await File(filePath).readAsBytes();
    return uploadBytes(dir,fileName,bytes,onSendProgress:onSendProgress);
  }
  static Future<Response> uploadBytes(String dir,String fileName,Uint8List bytes,{ProgressCallback onSendProgress}){
    var encrypt = isEncryptFileName(fileName);
    if(encrypt > 0){
      dir = 'Encrypt' + dir;
      switch(encrypt){
        case 1:
          bytes = SfUtils.encrypt(bytes);
          break;
        default:
          throw '不支持的加密方式!';
      }
    }
    return _uploadMultipartFile(dir,MultipartFile.fromBytes(bytes,filename:fileName),fileName:fileName,onSendProgress:onSendProgress);
  }
  static Future<Response> _uploadMultipartFile(String dir,MultipartFile file,{String fileName,ProgressCallback onSendProgress}){
    fileName = fileName ?? file.filename;
    FormData data = FormData.fromMap({
      'Filename': fileName,
      'key': '$dir/$fileName',
      'policy': policy,
      'OSSAccessKeyId': accessKeyId,
      'success_action_status': '200',
      'signature': signature,
      'file': file
    });
    Dio dio = Dio(BaseOptions(responseType: ResponseType.plain));
    return dio.post(endPoint,data: data,onSendProgress:onSendProgress);
  }
}

class SfAliyunOssResizeMode {
  static const lfit = 'lfit';//等比缩放,限制在指定w与h的矩形内的最大图片
  static const mfit = 'mfit';//等比缩放,延伸出指定w与h的矩形框外的最小图片
  static const fill = 'fill';//固定宽高,将延伸出指定w与h的矩形框外的最小图片进行居中裁剪
  static const fixed = 'fixed';//固定宽高,强制缩略
}