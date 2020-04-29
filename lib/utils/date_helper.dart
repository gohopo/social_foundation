class SfDateHelper{
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