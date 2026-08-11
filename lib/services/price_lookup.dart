import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// Ergebnis einer Preissuche.
class PriceLookupResult {
  const PriceLookupResult({this.price, this.title});

  /// Gefundener Preis, oder null wenn keiner ermittelt werden konnte.
  final double? price;

  /// Produktname laut Seite (og:title / <title>), falls vorhanden.
  final String? title;

  bool get hasPrice => price != null;
}

/// Gründe, warum eine Preissuche fehlschlagen kann - für klare Meldungen.
enum PriceLookupError { invalidUrl, network, blocked, notFound }

class PriceLookupException implements Exception {
  const PriceLookupException(this.reason, [this.statusCode]);

  final PriceLookupError reason;
  final int? statusCode;

  /// Nutzerfreundliche, ehrliche Fehlermeldung auf Deutsch.
  String get message => switch (reason) {
    PriceLookupError.invalidUrl =>
      'Das sieht nicht nach einem gültigen Link aus.',
    PriceLookupError.network =>
      'Die Seite konnte nicht geladen werden. Internet prüfen?',
    PriceLookupError.blocked =>
      'Der Shop blockiert automatische Zugriffe (Fehler $statusCode). '
          'Bitte den Preis von Hand eintragen.',
    PriceLookupError.notFound =>
      'Auf der Seite wurde kein Preis gefunden. '
          'Bitte von Hand eintragen.',
  };
}

/// Liest den Produktpreis aus den strukturierten Metadaten einer Webseite.
///
/// Bewusst *best effort*: Ausgewertet werden JSON-LD (schema.org Product),
/// OpenGraph-/Produkt-Meta-Tags und microdata `itemprop="price"`. Shops, die
/// ihren Preis erst per JavaScript nachladen oder Bots aussperren (z. B.
/// häufig Amazon), liefern deshalb kein Ergebnis - in dem Fall wird eine
/// [PriceLookupException] geworfen, damit der Nutzer den Preis manuell
/// eingeben kann. Es wird nie ein geratener Preis zurückgegeben.
class PriceLookupService {
  PriceLookupService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0 Safari/537.36';

  Future<PriceLookupResult> lookup(String rawUrl) async {
    final uri = _normalizeUrl(rawUrl);
    if (uri == null) {
      throw const PriceLookupException(PriceLookupError.invalidUrl);
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {
              'User-Agent': _userAgent,
              'Accept': 'text/html,application/xhtml+xml',
              'Accept-Language': 'de-DE,de;q=0.9,en;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const PriceLookupException(PriceLookupError.network);
    }

    if (response.statusCode != 200) {
      throw PriceLookupException(PriceLookupError.blocked, response.statusCode);
    }

    final document = html_parser.parse(
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );

    final price =
        _priceFromJsonLd(document) ??
        _priceFromMetaTags(document) ??
        _priceFromMicrodata(document);

    final title = _titleFrom(document);

    if (price == null) {
      throw const PriceLookupException(PriceLookupError.notFound);
    }
    return PriceLookupResult(price: price, title: title);
  }

  void dispose() => _client.close();

  /// Ergänzt fehlendes Schema und prüft, ob die URL brauchbar ist.
  static Uri? _normalizeUrl(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority || !uri.host.contains('.')) {
      return null;
    }
    return uri;
  }

  /// schema.org Product als JSON-LD - die zuverlässigste Quelle.
  static double? _priceFromJsonLd(Document document) {
    for (final script in document.querySelectorAll(
      'script[type="application/ld+json"]',
    )) {
      final raw = script.text.trim();
      if (raw.isEmpty) continue;

      Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        continue; // Fehlerhaftes JSON-LD einfach überspringen.
      }

      final price = _searchJsonForPrice(decoded);
      if (price != null) return price;
    }
    return null;
  }

  /// Durchsucht beliebig verschachteltes JSON nach einem `price`-Feld
  /// innerhalb eines `offers`-Objekts bzw. eines Product-Knotens.
  static double? _searchJsonForPrice(Object? node) {
    if (node is List) {
      for (final child in node) {
        final result = _searchJsonForPrice(child);
        if (result != null) return result;
      }
      return null;
    }
    if (node is! Map) return null;

    final offers = node['offers'];
    if (offers != null) {
      final fromOffers = _searchJsonForPrice(offers);
      if (fromOffers != null) return fromOffers;
    }

    for (final key in ['price', 'lowPrice', 'highPrice']) {
      final parsed = _parsePrice(node[key]);
      if (parsed != null) return parsed;
    }

    // @graph und ähnliche Container mit durchsuchen.
    for (final entry in node.entries) {
      if (entry.value is List || entry.value is Map) {
        final result = _searchJsonForPrice(entry.value);
        if (result != null) return result;
      }
    }
    return null;
  }

  /// OpenGraph-/Produkt-Meta-Tags.
  static double? _priceFromMetaTags(Document document) {
    const selectors = [
      'meta[property="product:price:amount"]',
      'meta[property="og:price:amount"]',
      'meta[name="product:price:amount"]',
      'meta[itemprop="price"]',
      'meta[name="twitter:data1"]',
    ];
    for (final selector in selectors) {
      final content = document.querySelector(selector)?.attributes['content'];
      final parsed = _parsePrice(content);
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// Microdata: <span itemprop="price" content="12.34"> oder Textinhalt.
  static double? _priceFromMicrodata(Document document) {
    for (final element in document.querySelectorAll('[itemprop="price"]')) {
      final parsed =
          _parsePrice(element.attributes['content']) ??
          _parsePrice(element.text);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String? _titleFrom(Document document) {
    final og = document
        .querySelector('meta[property="og:title"]')
        ?.attributes['content']
        ?.trim();
    if (og != null && og.isNotEmpty) return og;
    final title = document.querySelector('title')?.text.trim();
    if (title != null && title.isNotEmpty) return title;
    return null;
  }

  /// Wandelt Preisangaben in einen double um und beherrscht dabei sowohl
  /// deutsche ("1.299,00 €") als auch englische ("1,299.00") Schreibweise.
  static double? _parsePrice(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble() > 0 ? value.toDouble() : null;

    var text = value.toString().trim();
    if (text.isEmpty) return null;

    // Nur Ziffern, Punkt, Komma und Minus behalten.
    text = text.replaceAll(RegExp(r'[^0-9.,-]'), '');
    if (text.isEmpty) return null;

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');

    if (lastComma > lastDot) {
      // Deutsches Format: Punkt = Tausender, Komma = Dezimaltrenner.
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else if (lastDot > lastComma) {
      // Englisches Format: Komma = Tausender.
      text = text.replaceAll(',', '');
    } else {
      text = text.replaceAll(',', '');
    }

    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
