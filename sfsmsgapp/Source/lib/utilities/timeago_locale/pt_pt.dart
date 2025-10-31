import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class EuropeanPortugueseTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'há';
  @override
  String prefixFromNow() => 'daqui a';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'menos de um minuto';
  @override
  String aboutAMinute(int minutes) => 'um minuto';
  @override
  String minutes(int minutes) => '$minutes minutos';
  @override
  String aboutAnHour(int minutes) => 'cerca de uma hora';
  @override
  String hours(int hours) => '$hours horas';
  @override
  String aDay(int hours) => 'um dia';
  @override
  String days(int days) => '$days dias';
  @override
  String aboutAMonth(int days) => 'cerca de um mês';
  @override
  String months(int months) => '$months meses';
  @override
  String aboutAYear(int year) => 'cerca de um ano';
  @override
  String years(int years) => '$years anos';
  @override
  String wordSeparator() => ' ';
}
