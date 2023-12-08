import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SfRegExpExtension on RegExp {
  List<String> splitWithDelim(String input, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0]!);
      start = match.end;
    }
    result.add(input.substring(start));
    return result.where((x) => x.isNotEmpty).toList();
  }
}

extension SfStringExtension on String {
  List<String> splitWithDelim(RegExp pattern) => pattern.splitWithDelim(this);
}

extension SfSizeExtension on num {
  double get wh => this * min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
}

extension SfNumExtension on num {
  String toStringWithFraction(int fractionDigits){
    return this.toStringAsFixed(fractionDigits).replaceAll(RegExp(r'([.]*0+)(?!.*\d)'),'');
  }
}