class SfDateHelper{
  static bool isSameYear(DateTime dateLeft, DateTime dateRight){
    return dateLeft.year==dateRight.year;
  }
  static bool isSameMonth(DateTime dateLeft, DateTime dateRight){
    return dateLeft.month==dateRight.month && isSameYear(dateLeft,dateRight);
  }
  static bool isSameDay(DateTime dateLeft, DateTime dateRight){
    return dateLeft.day==dateRight.day && isSameMonth(dateLeft,dateRight);
  }
  static bool isFirstDayOfMonth(DateTime date){
    return date.day == 1;
  }
  static bool isThisYear(DateTime date){
    return isSameYear(date,DateTime.now());
  }
  static bool isThisMonth(DateTime date){
    return isSameMonth(date,DateTime.now());
  }
  static bool isToday(DateTime date){
    return isSameDay(date,DateTime.now());
  }
}