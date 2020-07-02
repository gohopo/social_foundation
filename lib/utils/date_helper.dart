import 'dart:math';

import 'package:common_utils/common_utils.dart';

class SfDateHelper{
  static String formatTimeline(int timestamp) => TimelineUtil.format(timestamp,locale:'zh');
  static String formatDate(DateTime date,{String format}) => DateUtil.formatDate(date,format:format);
  static String formatDateMs(int timestamp,{String format}) => DateUtil.formatDateMs(timestamp,format:format);
  static String formatDuration(Duration duration,{bool full,int minUnits,int maxUnits,String defaultUnit,String yearUnit,String dayUnit,String hourUnit,String minuteUnit,String secondUnit}) => formatDurationMs(duration.inMilliseconds,full:full,minUnits:minUnits,maxUnits:maxUnits,defaultUnit:defaultUnit,yearUnit:yearUnit,dayUnit:dayUnit,hourUnit:hourUnit,minuteUnit:minuteUnit,secondUnit:secondUnit);
  static String formatDurationMs(int milliseconds,{bool full,int minUnits,int maxUnits,String defaultUnit,String yearUnit,String dayUnit,String hourUnit,String minuteUnit,String secondUnit}){
    full ??= true;
    minUnits = max(1,min(minUnits??1,5));
    maxUnits = max(minUnits,min(maxUnits??2,5));
    defaultUnit ??= ':';
    var format = ''; 
    int millisecondsUnit = Duration.millisecondsPerDay*365;
    if(minUnits==5 || milliseconds>=millisecondsUnit){
      format += _formatValue((milliseconds/millisecondsUnit).floor(), full, yearUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerDay;
    if(minUnits==4 || maxUnits>0&&milliseconds>=millisecondsUnit){
      format += _formatValue((milliseconds/millisecondsUnit).floor(), full, dayUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerHour;
    if(minUnits==3 || maxUnits>0&&milliseconds>=millisecondsUnit){
      format += _formatValue((milliseconds/millisecondsUnit).floor(), full, hourUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerMinute;
    if(minUnits==2 || maxUnits>0&&milliseconds>=millisecondsUnit){
      format += _formatValue((milliseconds/millisecondsUnit).floor(), full, minuteUnit??defaultUnit);
      milliseconds %= millisecondsUnit;
      --minUnits;
      --maxUnits;
    }
    millisecondsUnit = Duration.millisecondsPerSecond;
    if(minUnits==1 || maxUnits>0&&milliseconds>=millisecondsUnit){
      format += _formatValue((milliseconds/millisecondsUnit).floor(), full, secondUnit??'');
    }
    return format;
  }

  static bool isSameYear(DateTime dateLeft, DateTime dateRight) => dateLeft.year==dateRight.year;
  static bool isSameMonth(DateTime dateLeft, DateTime dateRight) => dateLeft.month==dateRight.month && isSameYear(dateLeft,dateRight);
  static bool isSameDay(DateTime dateLeft, DateTime dateRight) => dateLeft.day==dateRight.day && isSameMonth(dateLeft,dateRight);
  static bool isSameHour(DateTime dateLeft, DateTime dateRight) => dateLeft.hour==dateRight.hour && isSameDay(dateLeft,dateRight);
  static bool isFirstDayOfMonth(DateTime date) => date.day==1;
  static bool isThisYear(DateTime date) => isSameYear(date,DateTime.now());
  static bool isThisMonth(DateTime date) => isSameMonth(date,DateTime.now());
  static bool isToday(DateTime date) => isSameDay(date,DateTime.now());
  static bool isThisHour(DateTime date) => isSameHour(date,DateTime.now());
  static DateTime startOfYear(DateTime date) => DateTime(date.year);
  static DateTime startOfMonth(DateTime date) => DateTime(date.year,date.month);
  static DateTime startOfDay(DateTime date) => DateTime(date.year,date.month,date.day);
  static DateTime startOfToday() => startOfDay(DateTime.now());
  static DateTime startOfTomorrow() => startOfToday().add(Duration(days:1));
  static DateTime startOfYesterday() => startOfToday().subtract(Duration(days:1));
  static DateTime endOfYear(DateTime date) => DateTime(date.year,12,31,23,59,59,999);
  static DateTime endOfDay(DateTime date) => DateTime(date.year,date.month,date.day,23,59,59,999);
  static DateTime endOfToday() => endOfDay(DateTime.now());
  static DateTime endOfTomorrow() => endOfToday().add(Duration(days:1));
  static DateTime endOfYesterday() => endOfToday().subtract(Duration(days:1));
  static Duration distanceBetweenDates(DateTime date, DateTime baseDate) => baseDate.difference(date);
  static Duration distanceToNow(DateTime baseDate) => distanceBetweenDates(DateTime.now(),baseDate);
  static Duration distanceToTomorrow() => distanceToNow(startOfTomorrow());
  static Duration distanceToYesterday() => distanceToNow(startOfToday());
}

String _formatValue(int value,bool full,String unit) => '${full&&value<10 ? 0 : ''}$value$unit';