import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Währungs- und Datumsformatierung, abhängig von der gewählten Sprache.
///
/// Deutsch: `1.299,00 €` · Englisch: `€1,299.00`. Die Währung bleibt Euro,
/// nur die Schreibweise folgt der Sprache.
class Formats {
  Formats(this.locale)
    : _currency = NumberFormat.currency(
        locale: locale,
        symbol: '€',
        decimalDigits: 2,
      ),
      _date = DateFormat.yMd(locale);

  /// Ableitung aus dem aktuellen [Localizations]-Kontext.
  factory Formats.of(BuildContext context) =>
      Formats(Localizations.localeOf(context).toLanguageTag());

  final String locale;
  final NumberFormat _currency;
  final DateFormat _date;

  /// Betrag als Euro-Angabe.
  String money(double value) => _currency.format(value);

  /// Wie [money], stellt positiven Beträgen aber ein "+" voran - für
  /// Listen, in denen Ein- und Auszahlungen gemischt auftreten.
  String signedMoney(double value) =>
      value > 0 ? '+${money(value)}' : money(value);

  /// Datum in der für die Sprache üblichen Schreibweise.
  String date(DateTime value) => _date.format(value);
}
