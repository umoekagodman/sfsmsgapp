// Import Third Party Packages
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

// Import Locale Files
import 'ar.dart';
import 'de.dart';
import 'el.dart';
import 'es.dart';
import 'fr.dart';
import 'it.dart';
import 'nl.dart';
import 'pt_br.dart';
import 'pt_pt.dart';
import 'ro.dart';
import 'ru.dart';
import 'tr.dart';

void setLocaleMessagesForLocale(String languageCode) {
  final code = languageCode.split('_');
  final baseLanguageCode = code[0];
  final countryCode = code.length > 1 ? code[1] : null;
  switch (baseLanguageCode) {
    case 'ar':
      timeago.setLocaleMessages('ar', ArabicTimeagoMessages());
      break;
    case 'de':
      timeago.setLocaleMessages('de', GermanTimeagoMessages());
      break;
    case 'el':
      timeago.setLocaleMessages('el', GreekTimeagoMessages());
      break;
    case 'es':
      timeago.setLocaleMessages('es', SpanishTimeagoMessages());
      break;
    case 'fr':
      timeago.setLocaleMessages('fr', FrenchTimeagoMessages());
      break;
    case 'it':
      timeago.setLocaleMessages('it', ItalianTimeagoMessages());
      break;
    case 'nl':
      timeago.setLocaleMessages('nl', DutchTimeagoMessages());
      break;
    case 'pt':
      if (countryCode == 'BR') {
        timeago.setLocaleMessages('pt_BR', BrazilianPortugueseTimeagoMessages());
      } else {
        timeago.setLocaleMessages('pt', EuropeanPortugueseTimeagoMessages());
      }
      break;
    case 'ro':
      timeago.setLocaleMessages('ro', RomanianTimeagoMessages());
      break;
    case 'ru':
      timeago.setLocaleMessages('ru', RussianTimeagoMessages());
      break;
    case 'tr':
      timeago.setLocaleMessages('tr', TurkishTimeagoMessages());
      break;
  }
}
