import 'package:intl/intl.dart';

/// Deutsche Währungsformatierung: 11999.0 -> "11.999,00 €".
final NumberFormat _euroFormat = NumberFormat.currency(
  locale: 'de_DE',
  symbol: '€',
  decimalDigits: 2,
);

/// Formatiert einen Betrag als Euro-Angabe im deutschen Format.
String formatEuro(double value) => _euroFormat.format(value);

/// Wie [formatEuro], stellt positiven Beträgen aber ein "+" voran -
/// für Listen, in denen Ein- und Auszahlungen gemischt auftreten.
String formatEuroSigned(double value) =>
    value > 0 ? '+${formatEuro(value)}' : formatEuro(value);
