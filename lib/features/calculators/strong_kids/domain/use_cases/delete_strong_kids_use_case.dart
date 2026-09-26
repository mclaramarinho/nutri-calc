import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/repositories/strong_kids_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteStrongKidsUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteStrongKidsUseCase)
class DeleteStrongKidsUseCaseImpl implements DeleteStrongKidsUseCase {
  const DeleteStrongKidsUseCaseImpl({required this._repository});

  final StrongKidsRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteStrongKidsCalculation(id);
}
