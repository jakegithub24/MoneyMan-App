import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/currency_item.dart';
import '../../../domain/repositories/expense_repository.dart';
import 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final ExpenseRepository repository;

  CurrencyCubit(this.repository) : super(CurrencyInitial()) {
    loadCurrency();
  }

  Future<void> loadCurrency() async {
    final code = await repository.getCurrencyCode();
    final item = CurrencyItem.getByCode(code);
    emit(CurrencyLoaded(item));
  }

  Future<void> changeCurrency(CurrencyItem newCurrency) async {
    await repository.setCurrency(newCurrency.code, newCurrency.symbol);
    emit(CurrencyLoaded(newCurrency));
  }
}
