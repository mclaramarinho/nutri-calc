import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/repositories/water_needs_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteWaterNeedsUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteWaterNeedsUseCase)
class DeleteWaterNeedsUseCaseImpl implements DeleteWaterNeedsUseCase {
  const DeleteWaterNeedsUseCaseImpl({required this._repository});

  final WaterNeedsRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteWaterNeeds(id);
}
