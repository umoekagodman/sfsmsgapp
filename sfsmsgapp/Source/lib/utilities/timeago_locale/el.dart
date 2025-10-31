import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class GreekTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'πριν';
  @override
  String prefixFromNow() => 'σε';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'λιγότερο από ένα λεπτό';
  @override
  String aboutAMinute(int minutes) => 'ένα λεπτό';
  @override
  String minutes(int minutes) => '$minutes λεπτά';
  @override
  String aboutAnHour(int minutes) => 'περίπου μία ώρα';
  @override
  String hours(int hours) => '$hours ώρες';
  @override
  String aDay(int hours) => 'μία μέρα';
  @override
  String days(int days) => '$days μέρες';
  @override
  String aboutAMonth(int days) => 'περίπου ένα μήνα';
  @override
  String months(int months) => '$months μήνες';
  @override
  String aboutAYear(int year) => 'περίπου ένα χρόνο';
  @override
  String years(int years) => '$years χρόνια';
  @override
  String wordSeparator() => ' ';
}
