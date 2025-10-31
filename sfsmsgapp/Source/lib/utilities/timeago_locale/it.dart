import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class ItalianTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'circa';
  @override
  String prefixFromNow() => 'tra';
  @override
  String suffixAgo() => 'fa';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'meno di un minuto';
  @override
  String aboutAMinute(int minutes) => 'un minuto';
  @override
  String minutes(int minutes) => '$minutes minuti';
  @override
  String aboutAnHour(int minutes) => 'circa un\'ora';
  @override
  String hours(int hours) => '$hours ore';
  @override
  String aDay(int hours) => 'un giorno';
  @override
  String days(int days) => '$days giorni';
  @override
  String aboutAMonth(int days) => 'circa un mese';
  @override
  String months(int months) => '$months mesi';
  @override
  String aboutAYear(int year) => 'circa un anno';
  @override
  String years(int years) => '$years anni';
  @override
  String wordSeparator() => ' ';
}
