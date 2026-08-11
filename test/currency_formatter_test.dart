import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_101/presentation/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Formats INR currency with Indian Lakhs and Crores digit notation', () {
      final formatted = CurrencyFormatter.formatAmount(
        240645520.46,
        currencyCode: 'INR',
        symbolOverride: 'Rs. ',
      );
      expect(formatted, equals('Rs. 24,06,45,520.46'));
    });

    test('Formats INR currency with default Rupee symbol', () {
      final formatted = CurrencyFormatter.formatAmount(
        1234567.89,
        currencyCode: 'INR',
      );
      expect(formatted, equals('₹12,34,567.89'));
    });

    test('Formats USD currency with Western Millions digit notation', () {
      final formatted = CurrencyFormatter.formatAmount(
        123445225.66,
        currencyCode: 'USD',
      );
      expect(formatted, equals('\$123,445,225.66'));
    });

    test('Formats EUR currency with Western Millions digit notation', () {
      final formatted = CurrencyFormatter.formatAmount(
        987654321.00,
        currencyCode: 'EUR',
      );
      expect(formatted, equals('€987,654,321.00'));
    });

    test('Formats JPY currency with 0 decimal places', () {
      final formatted = CurrencyFormatter.formatAmount(
        12345678.0,
        currencyCode: 'JPY',
      );
      expect(formatted, equals('¥12,345,678'));
    });

    test('Formats amount without symbol when showSymbol is false', () {
      final formattedINR = CurrencyFormatter.formatAmount(
        543210.0,
        currencyCode: 'INR',
        showSymbol: false,
      );
      expect(formattedINR, equals('5,43,210.00'));

      final formattedUSD = CurrencyFormatter.formatAmount(
        543210.0,
        currencyCode: 'USD',
        showSymbol: false,
      );
      expect(formattedUSD, equals('543,210.00'));
    });
  });
}
