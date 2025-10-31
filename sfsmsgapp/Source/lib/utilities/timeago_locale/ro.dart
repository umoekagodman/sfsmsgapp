import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class RomanianTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'acum';
  @override
  String prefixFromNow() => 'peste';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'mai puțin de un minut';
  @override
  String aboutAMinute(int minutes) => 'un minut';
  @override
  String minutes(int minutes) => '$minutes minute';
  @override
  String aboutAnHour(int minutes) => 'aproximativ o oră';
  @override
  String hours(int hours) => '$hours ore';
  @override
  String aDay(int hours) => 'o zi';
  @override
  String days(int days) => '$days zile';
  @override
  String aboutAMonth(int days) => 'aproximativ o lună';
  @override
  String months(int months) => '$months luni';
  @override
  String aboutAYear(int year) => 'aproximativ un an';
  @override
  String years(int years) => '$years ani';
  @override
  String wordSeparator() => ' ';
}
