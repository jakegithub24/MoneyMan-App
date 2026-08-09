import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_101/domain/entities/currency_item.dart';

void main() {
  group('Currency Management Tests', () {
    test('Available currencies contain INR, USD, EUR, GBP, JPY, etc.', () {
      final list = CurrencyItem.availableCurrencies;
      expect(list.any((c) => c.code == 'INR'), isTrue);
      expect(list.any((c) => c.code == 'USD'), isTrue);
      expect(list.any((c) => c.code == 'EUR'), isTrue);
      expect(list.any((c) => c.code == 'GBP'), isTrue);
      expect(list.any((c) => c.code == 'JPY'), isTrue);
    });

    test('Currency lookup by code works accurately', () {
      final inr = CurrencyItem.getByCode('INR');
      expect(inr.symbol, equals('₹'));
      expect(inr.name, equals('Indian Rupee'));

      final usd = CurrencyItem.getByCode('USD');
      expect(usd.symbol, equals('\$'));
      expect(usd.name, equals('US Dollar'));

      final yen = CurrencyItem.getByCode('JPY');
      expect(yen.symbol, equals('¥'));
      expect(yen.name, equals('Japanese Yen'));
    });
  });
}
