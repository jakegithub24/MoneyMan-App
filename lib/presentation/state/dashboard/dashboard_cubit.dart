import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/use_cases/get_summary_usecase.dart';
import '../../../application/use_cases/list_expenses_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetSummaryUseCase getSummaryUseCase;
  final ListExpensesUseCase listExpensesUseCase;

  DashboardCubit({
    required this.getSummaryUseCase,
    required this.listExpensesUseCase,
  }) : super(DashboardInitial());

  Future<void> loadDashboard({DateFilterType filterType = DateFilterType.thisMonth}) async {
    emit(DashboardLoading());
    try {
      final now = DateTime.now();
      DateTime? from;
      DateTime? to;

      switch (filterType) {
        case DateFilterType.today:
          from = DateTime(now.year, now.month, now.day);
          to = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case DateFilterType.thisWeek:
          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          from = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          to = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
          break;
        case DateFilterType.thisMonth:
          from = DateTime(now.year, now.month, 1);
          to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case DateFilterType.thisYear:
          from = DateTime(now.year, 1, 1);
          to = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case DateFilterType.all:
          from = null;
          to = null;
          break;
      }

      final summary = await getSummaryUseCase.execute(from: from, to: to);
      final recent = await listExpensesUseCase.execute(from: from, to: to);

      emit(DashboardLoaded(
        summary: summary,
        recentExpenses: recent.take(5).toList(),
        filterType: filterType,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
