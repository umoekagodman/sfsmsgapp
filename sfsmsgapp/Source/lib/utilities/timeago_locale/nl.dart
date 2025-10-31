import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class DutchTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'over';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => '<1m';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '~1u';
  @override
  String hours(int hours) => '${hours}u';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '~1mnd';
  @override
  String months(int months) => '${months}mnd';
  @override
  String aboutAYear(int year) => '~1j';
  @override
  String years(int years) => '${years}j';
  @override
  String wordSeparator() => '';
}
