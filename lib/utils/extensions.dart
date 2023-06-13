import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';

extension RegExpExtension on RegExp {
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

extension StringExtension on String {
  List<String> splitWithDelim(RegExp pattern) => pattern.splitWithDelim(this);
}

extension SfSizeExtension on num {
  double get wh => this * min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
}