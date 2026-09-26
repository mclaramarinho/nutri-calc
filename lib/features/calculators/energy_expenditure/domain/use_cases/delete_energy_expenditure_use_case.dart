import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/repositories/energy_expenditure_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteEnergyExpenditureUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteEnergyExpenditureUseCase)
class DeleteEnergyExpenditureUseCaseImpl implements DeleteEnergyExpenditureUseCase {
  const DeleteEnergyExpenditureUseCaseImpl({required this._repository});

  final EnergyExpenditureRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteEnergyExpenditure(id);
}
