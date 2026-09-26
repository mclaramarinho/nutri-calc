import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';

/// Reused directly by both `PatientDetailsCubit.deleteWeight` and
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010) - never duplicated, so a
/// Weight-type row deleted from History and from the Weights tab always go
/// through the exact same leaf delete.
abstract class DeleteWeightUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteWeightUseCase)
class DeleteWeightUseCaseImpl implements DeleteWeightUseCase {
  const DeleteWeightUseCaseImpl({required this._repository});

  final WeightRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteWeight(id);
}
