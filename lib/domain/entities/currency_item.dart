class CurrencyItem {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyItem({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  static const List<CurrencyItem> availableCurrencies = [
    CurrencyItem(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    CurrencyItem(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyItem(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    CurrencyItem(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    CurrencyItem(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    CurrencyItem(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    CurrencyItem(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    CurrencyItem(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    CurrencyItem(code: 'AED', symbol: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
    CurrencyItem(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    CurrencyItem(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
    CurrencyItem(code: 'RUB', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
  ];

  static CurrencyItem getByCode(String code) {
    return availableCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => availableCurrencies.first, // Default INR
    );
  }
}
