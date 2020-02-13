class SfResponse {
  int code;
  dynamic result;
  String message;
  SfResponse(this.code, this.result, this.message);
  SfResponse.fromJson(Map data) : this(data['code'],data['result'],data['message']);
}