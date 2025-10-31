import 'package:timeago_flutter/timeago_flutter.dart';

class ArabicTimeagoMessages implements LookupMessages {
  @override
  String prefixAgo() => 'منذ';
  @override
  String prefixFromNow() => 'في';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'الآن';
  @override
  String aboutAMinute(int minutes) => 'دقيقة';
  @override
  String minutes(int minutes) => '$minutes دقائق';
  @override
  String aboutAnHour(int minutes) => 'حوالي ساعة';
  @override
  String hours(int hours) => '$hours ساعات';
  @override
  String aDay(int hours) => 'يوم';
  @override
  String days(int days) => '$days أيام';
  @override
  String aboutAMonth(int days) => 'حوالي شهر';
  @override
  String months(int months) => '$months أشهر';
  @override
  String aboutAYear(int year) => 'حوالي سنة';
  @override
  String years(int years) => '$years سنوات';
  @override
  String wordSeparator() => ' ';
}
