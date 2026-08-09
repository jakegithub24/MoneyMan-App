import '../../../domain/entities/currency_item.dart';

abstract class CurrencyState {
  final CurrencyItem currency;
  const CurrencyState(this.currency);
}

class CurrencyInitial extends CurrencyState {
  CurrencyInitial() : super(CurrencyItem.getByCode('INR'));
}

class CurrencyLoaded extends CurrencyState {
  const CurrencyLoaded(super.currency);
}
