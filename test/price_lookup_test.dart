// Tests für die Preiserkennung aus Produktseiten.
// Es wird ein Fake-HTTP-Client benutzt, es gehen also keine echten
// Anfragen ins Netz.

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spartracker/services/price_lookup.dart';

PriceLookupService serviceReturning(String body, {int status = 200}) {
  final client = MockClient((request) async {
    return http.Response(body, status, headers: {
      'content-type': 'text/html; charset=utf-8',
    });
  });
  return PriceLookupService(client: client);
}

void main() {
  group('Preis aus JSON-LD', () {
    test('liest offers.price', () async {
      final service = serviceReturning('''
        <html><head>
        <script type="application/ld+json">
        {"@type":"Product","name":"Fahrrad",
         "offers":{"@type":"Offer","price":"449.99","priceCurrency":"EUR"}}
        </script>
        </head><body></body></html>
      ''');
      final result = await service.lookup('https://shop.example/fahrrad');
      expect(result.price, 449.99);
    });

    test('findet Product auch innerhalb von @graph', () async {
      final service = serviceReturning('''
        <html><head>
        <script type="application/ld+json">
        {"@graph":[{"@type":"WebPage"},
                   {"@type":"Product","offers":{"price":129.5}}]}
        </script>
        </head><body></body></html>
      ''');
      final result = await service.lookup('https://shop.example/x');
      expect(result.price, 129.5);
    });

    test('überspringt kaputtes JSON-LD und nutzt Meta-Tag', () async {
      final service = serviceReturning('''
        <html><head>
        <script type="application/ld+json">{ das ist kein json }</script>
        <meta property="product:price:amount" content="59.00">
        </head><body></body></html>
      ''');
      final result = await service.lookup('https://shop.example/x');
      expect(result.price, 59.0);
    });
  });

  group('Zahlenformate', () {
    test('deutsches Format mit Tausenderpunkt', () async {
      final service = serviceReturning(
        '<html><head><meta itemprop="price" content="1.299,00 €">'
        '</head><body></body></html>',
      );
      final result = await service.lookup('https://shop.example/x');
      expect(result.price, 1299.00);
    });

    test('englisches Format mit Tausenderkomma', () async {
      final service = serviceReturning(
        '<html><head><meta property="og:price:amount" content="1,299.00">'
        '</head><body></body></html>',
      );
      final result = await service.lookup('https://shop.example/x');
      expect(result.price, 1299.00);
    });

    test('Microdata mit Text statt content-Attribut', () async {
      final service = serviceReturning(
        '<html><body><span itemprop="price">24,99 €</span></body></html>',
      );
      final result = await service.lookup('https://shop.example/x');
      expect(result.price, 24.99);
    });
  });

  group('Titel', () {
    test('bevorzugt og:title', () async {
      final service = serviceReturning('''
        <html><head>
        <title>Shop - Fahrrad kaufen</title>
        <meta property="og:title" content="Cooles Fahrrad">
        <meta itemprop="price" content="100">
        </head><body></body></html>
      ''');
      final result = await service.lookup('https://shop.example/x');
      expect(result.title, 'Cooles Fahrrad');
    });
  });

  group('Fehlerfälle - es wird nie ein geratener Preis geliefert', () {
    test('kein Preis auf der Seite', () async {
      final service = serviceReturning(
        '<html><body><p>Preis auf Anfrage</p></body></html>',
      );
      expect(
        () => service.lookup('https://shop.example/x'),
        throwsA(isA<PriceLookupException>().having(
          (e) => e.reason,
          'reason',
          PriceLookupError.notFound,
        )),
      );
    });

    test('Shop blockiert mit 403', () async {
      final service = serviceReturning('<html></html>', status: 403);
      expect(
        () => service.lookup('https://shop.example/x'),
        throwsA(isA<PriceLookupException>().having(
          (e) => e.reason,
          'reason',
          PriceLookupError.blocked,
        )),
      );
    });

    test('ungültige URL', () async {
      final service = serviceReturning('<html></html>');
      expect(
        () => service.lookup('nicht mal ansatzweise eine url'),
        throwsA(isA<PriceLookupException>().having(
          (e) => e.reason,
          'reason',
          PriceLookupError.invalidUrl,
        )),
      );
    });

    test('Preis 0 gilt nicht als Treffer', () async {
      final service = serviceReturning(
        '<html><head><meta itemprop="price" content="0,00">'
        '</head><body></body></html>',
      );
      expect(
        () => service.lookup('https://shop.example/x'),
        throwsA(isA<PriceLookupException>()),
      );
    });
  });

  test('URL ohne Schema wird ergänzt', () async {
    final service = serviceReturning(
      '<html><head><meta itemprop="price" content="10"></head></html>',
    );
    final result = await service.lookup('shop.example/produkt');
    expect(result.price, 10.0);
  });
}
