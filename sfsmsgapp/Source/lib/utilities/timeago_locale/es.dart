import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class SpanishTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'hace';
  @override
  String prefixFromNow() => 'dentro de';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'menos de un minuto';
  @override
  String aboutAMinute(int minutes) => 'un minuto';
  @override
  String minutes(int minutes) => '$minutes minutos';
  @override
  String aboutAnHour(int minutes) => 'aproximadamente una hora';
  @override
  String hours(int hours) => '$hours horas';
  @override
  String aDay(int hours) => 'un día';
  @override
  String days(int days) => '$days días';
  @override
  String aboutAMonth(int days) => 'aproximadamente un mes';
  @override
  String months(int months) => '$months meses';
  @override
  String aboutAYear(int year) => 'aproximadamente un año';
  @override
  String years(int years) => '$years años';
  @override
  String wordSeparator() => ' ';
}
