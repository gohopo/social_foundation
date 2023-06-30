import 'dart:math';

import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:social_foundation/utils/utils.dart';

class SfDateHelper{
  static String formatTimeline(int timestamp) => TimelineUtil.format(timestamp,locale:'zh');
  static String formatDate(DateTime date,{String? format}) => DateUtil.formatDate(date,format:format);
  static String formatDateMs(int timestamp,{String? format}) => DateUtil.formatDateMs(timestamp,format:format);
  static String formatDuration(Duration duration,{bool? full,int? minUnits,int? maxUnits,String? defaultUnit,String? yearUnit,String? dayUnit,String? hourUnit,String? minuteUnit,String? secondUnit,int? minUnit,int? maxUnit}) => formatDurationMs(duration.inMilliseconds,full:full,minUnits:minUnits,maxUnits:maxUnits,defaultUnit:defaultUnit,yearUnit:yearUnit,dayUnit:dayUnit,hourUnit:hourUnit,minuteUnit:minuteUnit,secondUnit:secondUnit,minUnit:minUnit,maxUnit:maxUnit);
  static String formatDurationMs(int milliseconds,{bool? full,int? minUnits,int? maxUnits,String? defaultUnit,String? yearUnit,String? dayUnit,String? hourUnit,String? minuteUnit,String? secondUnit,int? minUnit,int? maxUnit}) => splitDurationMs(milliseconds,full:full,minUnits:minUnits,maxUnits:maxUnits,defaultUnit:defaultUnit,yearUnit:yearUnit,dayUnit:dayUnit,hourUnit:hourUnit,minuteUnit:minuteUnit,secondUnit:secondUnit,minUnit:minUnit,maxUnit:maxUnit).join();
  static List<String> splitDuration(Duration duration,{bool? full,int? minUnits,int? maxUnits,String? defaultUnit,String? yearUnit,String? dayUnit,String? hourUnit,String? minuteUnit,String? secondUnit,int? minUnit,int? maxUnit}) => splitDurationMs(duration.inMilliseconds,full:full,minUnits:minUnits,maxUnits:maxUnits,defaultUnit:defaultUnit,yearUnit:yearUnit,dayUnit:dayUnit,hourUnit:hourUnit,minuteUnit:minuteUnit,secondUnit:secondUnit,minUnit:minUnit,maxUnit:maxUnit);
  ///格式化持续时间
  ///[milliseconds] 持续时间,单位毫秒
  ///[full] 是否有前導零
  ///[minUnits] 最少单位数量
  ///[maxUnits] 最多单位数量
  ///[defaultUnit] 默认单位:
  ///[yearUnit] 年单位
  ///[dayUnit] 天单位
  ///[hourUnit] 时单位
  ///[minuteUnit] 分单位
  ///[secondUnit] 秒单位
  ///[minUnit] 最小单位,默认为0.(年:4 天:3 时:2 分:1 秒:0)
  static List<String> splitDurationMs(int milliseconds,{bool? full,int? minUnits,int? maxUnits,String? defaultUnit,String? yearUnit,String? dayUnit,String? hourUnit,String? minuteUnit,String? secondUnit,int? minUnit,int? maxUnit}){
    full ??= true;
    minUnit = max(0,min(minUnit??0,4));
    maxUnit = max(minUnit,min(maxUnit??4,4));
    minUnits = max(1,min(minUnits??1,5-minUnit));
    maxUnits = max(minUnits,min(maxUnits??2,5-minUnit));
    defaultUnit ??= ':';
    List<String> format = []; 
    int millisecondsUnit = Duration.millisecondsPerDay*365;
    if(maxUnit>=4 && (minUnits==5-minUnit || milliseconds>=millisecondsUnit)){
      format.add(SfUtils.padValue((milliseconds/millisecondsUnit).floor(),pad:false));
      format.add(yearUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerDay;
    if(minUnit<=3 && maxUnit>=3 && (minUnits==4-minUnit || maxUnits>0&&milliseconds>=millisecondsUnit)){
      format.add(SfUtils.padValue((milliseconds/millisecondsUnit).floor(),pad:full));
      format.add(dayUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerHour;
    if(minUnit<=2 && maxUnit>=2 && (minUnits==3-minUnit || maxUnits>0&&milliseconds>=millisecondsUnit)){
      format.add(SfUtils.padValue((milliseconds/millisecondsUnit).floor(),pad:full));
      format.add(hourUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerMinute;
    if(minUnit<=1 && maxUnit>=1 && (minUnits==2-minUnit || maxUnits>0&&milliseconds>=millisecondsUnit)){
      format.add(SfUtils.padValue((milliseconds/millisecondsUnit).floor(),pad:full));
      format.add(minuteUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerSecond;
    if(minUnit<=0 && (minUnits==1-minUnit || maxUnits>0&&milliseconds>=millisecondsUnit)){
      format.add(SfUtils.padValue((milliseconds/millisecondsUnit).floor(),pad:full));
      format.add(secondUnit??defaultUnit);
    }
    if(format.lastOrNull==defaultUnit) format.removeLast();
    return format;
  }

  static bool isSameYear(DateTime dateLeft, DateTime dateRight) => dateLeft.year==dateRight.year;
  static bool isSameMonth(DateTime dateLeft, DateTime dateRight) => dateLeft.month==dateRight.month && isSameYear(dateLeft,dateRight);
  static bool isSameWeek(DateTime dateLeft, DateTime dateRight) => startOfWeek(dateLeft)==startOfWeek(dateRight);
  static bool isSameDay(DateTime dateLeft, DateTime dateRight) => dateLeft.day==dateRight.day && isSameMonth(dateLeft,dateRight);
  static bool isSameHour(DateTime dateLeft, DateTime dateRight) => dateLeft.hour==dateRight.hour && isSameDay(dateLeft,dateRight);
  static bool isFirstDayOfMonth(DateTime date) => date.day==1;
  static bool isThisYear(DateTime date) => isSameYear(date,DateTime.now());
  static bool isThisMonth(DateTime date) => isSameMonth(date,DateTime.now());
  static bool isThisWeek(DateTime date) => isSameWeek(date,DateTime.now());
  static bool isLastYear(DateTime date) => isSameYear(date,startOfThisYear().subtract(Duration(days:1)));
  static bool isLastMonth(DateTime date) => isSameMonth(date,startOfThisMonth().subtract(Duration(days:1)));
  static bool isLastWeek(DateTime date) => isSameWeek(date,startOfThisWeek().subtract(Duration(days:1)));
  static bool isToday(DateTime date) => isSameDay(date,DateTime.now());
  static bool isThisHour(DateTime date) => isSameHour(date,DateTime.now());
  static DateTime startOfYear(DateTime date) => DateTime(date.year);
  static DateTime startOfMonth(DateTime date) => DateTime(date.year,date.month);
  static DateTime startOfWeek(DateTime date) => startOfDay(date).subtract(Duration(days:date.weekday-1));
  static DateTime startOfDay(DateTime date) => DateTime(date.year,date.month,date.day);
  static DateTime startOfThisYear() => startOfYear(DateTime.now());
  static DateTime startOfThisMonth() => startOfMonth(DateTime.now());
  static DateTime startOfThisWeek() => startOfWeek(DateTime.now());
  static DateTime startOfLastYear() => startOfYear(startOfThisYear().subtract(Duration(days:1)));
  static DateTime startOfLastMonth() => startOfMonth(startOfThisMonth().subtract(Duration(days:1)));
  static DateTime startOfLastWeek() => startOfWeek(DateTime.now().subtract(Duration(days:7)));
  static DateTime startOfToday() => startOfDay(DateTime.now());
  static DateTime startOfTomorrow() => startOfToday().add(Duration(days:1));
  static DateTime startOfYesterday() => startOfToday().subtract(Duration(days:1));
  static DateTime endOfYear(DateTime date) => DateTime(date.year,12,31,23,59,59,999);
  static DateTime endOfMonth(DateTime date) => DateTime(date.year,date.month+1).subtract(Duration(milliseconds:1));
  static DateTime endOfWeek(DateTime date) => endOfDay(date).add(Duration(days:7-date.weekday));
  static DateTime endOfDay(DateTime date) => DateTime(date.year,date.month,date.day,23,59,59,999);
  static DateTime endOfThisYear() => endOfYear(DateTime.now());
  static DateTime endOfThisMonth() => endOfMonth(DateTime.now());
  static DateTime endOfThisWeek() => endOfWeek(DateTime.now());
  static DateTime endOfLastYear() => endOfYear(startOfThisYear().subtract(Duration(days:1)));
  static DateTime endOfLastMonth() => endOfMonth(startOfThisMonth().subtract(Duration(days:1)));
  static DateTime endOfLastWeek() => endOfWeek(DateTime.now().subtract(Duration(days:7)));
  static DateTime endOfToday() => endOfDay(DateTime.now());
  static DateTime endOfTomorrow() => endOfToday().add(Duration(days:1));
  static DateTime endOfYesterday() => endOfToday().subtract(Duration(days:1));
  static Duration distanceBetweenDates(DateTime date, DateTime baseDate) => baseDate.difference(date);
  static Duration distanceToNow(DateTime baseDate) => distanceBetweenDates(DateTime.now(),baseDate);
  static Duration distanceToNowMs(int timestamp) => distanceToNow(DateTime.fromMillisecondsSinceEpoch(timestamp));
  static Duration distanceToTomorrow() => distanceToNow(startOfTomorrow());
  static Duration distanceToYesterday() => distanceToNow(startOfToday());
  static bool isAfter(DateTime date, DateTime baseDate) => distanceBetweenDates(baseDate,date).inMilliseconds>0;
  static bool isBefore(DateTime date, DateTime baseDate) => distanceBetweenDates(baseDate,date).inMilliseconds<0;
  static bool isAfterNow(DateTime date) => isAfter(date,DateTime.now());
  static bool isBeforeNow(DateTime date) => isBefore(date,DateTime.now());
}
