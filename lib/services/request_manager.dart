import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class SfRequestManager{
  SfRequestManager({
    String baseUrl
  }) : _dio=Dio(BaseOptions(baseUrl:baseUrl));
  Dio _dio;

  Future<dynamic> invokeFunction(String controller,String function,Map body) async {
    try{
      var path = controller.isNotEmpty ? p.join(controller,function) : function;
      var response = await _dio.post(path,data: body);
      return response.data;
    }
    catch(e){
      throw e.response.data['errorMessage'];
    }
  }
}