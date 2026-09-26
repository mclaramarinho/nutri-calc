import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/must/domain/repositories/must_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteMustUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteMustUseCase)
class DeleteMustUseCaseImpl implements DeleteMustUseCase {
  const DeleteMustUseCaseImpl({required this._repository});

  final MustRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteMustCalculation(id);
}
