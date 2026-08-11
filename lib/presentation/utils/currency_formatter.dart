import 'package:intl/intl.dart';

/// Utility to format currency values using appropriate digit notation:
/// - Indian Rupee (INR): Uses Lakhs and Crores notation (e.g., Rs. 24,06,45,520.46)
/// - International (USD, EUR, GBP, etc.): Uses Thousands and Millions notation (e.g., $123,445,225.66)
class CurrencyFormatter {
  static String formatAmount(
    double amount, {
    required String currencyCode,
    int decimalDigits = 2,
    bool showSymbol = true,
    String? symbolOverride,
  }) {
    final codeUpper = currencyCode.toUpperCase();
    final isZeroDecimal = codeUpper == 'JPY' || codeUpper == 'KRW';
    final decimals = isZeroDecimal ? 0 : decimalDigits;

    final String locale = codeUpper == 'INR' ? 'en_IN' : 'en_US';

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: decimals,
    );

    final formattedNumber = formatter.format(amount).trim();

    if (!showSymbol) {
      return formattedNumber;
    }

    final symbol = symbolOverride ?? _getSymbolForCode(codeUpper);
    return '$symbol$formattedNumber';
  }

  static String _getSymbolForCode(String code) {
    switch (code) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      default:
        return '$code ';
    }
  }
}
