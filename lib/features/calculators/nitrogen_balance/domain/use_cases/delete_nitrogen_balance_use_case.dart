import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/repositories/nitrogen_balance_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteNitrogenBalanceUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteNitrogenBalanceUseCase)
class DeleteNitrogenBalanceUseCaseImpl implements DeleteNitrogenBalanceUseCase {
  const DeleteNitrogenBalanceUseCaseImpl({required this._repository});

  final NitrogenBalanceRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteNitrogenBalance(id);
}
