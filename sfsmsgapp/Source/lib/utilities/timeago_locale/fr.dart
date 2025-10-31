import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class FrenchTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'il y a';
  @override
  String prefixFromNow() => 'dans';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'moins d\'une minute';
  @override
  String aboutAMinute(int minutes) => 'une minute';
  @override
  String minutes(int minutes) => '$minutes minutes';
  @override
  String aboutAnHour(int minutes) => 'environ une heure';
  @override
  String hours(int hours) => '$hours heures';
  @override
  String aDay(int hours) => 'un jour';
  @override
  String days(int days) => '$days jours';
  @override
  String aboutAMonth(int days) => 'environ un mois';
  @override
  String months(int months) => '$months mois';
  @override
  String aboutAYear(int year) => 'environ un an';
  @override
  String years(int years) => '$years ans';
  @override
  String wordSeparator() => ' ';
}
