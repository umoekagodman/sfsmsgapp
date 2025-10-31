import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class RussianTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'через';
  @override
  String suffixAgo() => 'назад';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'меньше минуты';
  @override
  String aboutAMinute(int minutes) => 'минуту';
  @override
  String minutes(int minutes) => '$minutes ${_pluralize(minutes, 'минуту', 'минуты', 'минут')}';
  @override
  String aboutAnHour(int minutes) => 'около часа';
  @override
  String hours(int hours) => '$hours ${_pluralize(hours, 'час', 'часа', 'часов')}';
  @override
  String aDay(int hours) => 'день';
  @override
  String days(int days) => '$days ${_pluralize(days, 'день', 'дня', 'дней')}';
  @override
  String aboutAMonth(int days) => 'около месяца';
  @override
  String months(int months) => '$months ${_pluralize(months, 'месяц', 'месяца', 'месяцев')}';
  @override
  String aboutAYear(int year) => 'около года';
  @override
  String years(int years) => '$years ${_pluralize(years, 'год', 'года', 'лет')}';
  @override
  String wordSeparator() => ' ';

  String _pluralize(int n, String one, String few, String many) {
    if (n % 10 == 1 && n % 100 != 11) return one;
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return few;
    return many;
  }
}
