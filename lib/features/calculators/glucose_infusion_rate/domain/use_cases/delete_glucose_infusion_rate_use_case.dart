import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/repositories/glucose_infusion_rate_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteGlucoseInfusionRateUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteGlucoseInfusionRateUseCase)
class DeleteGlucoseInfusionRateUseCaseImpl implements DeleteGlucoseInfusionRateUseCase {
  const DeleteGlucoseInfusionRateUseCaseImpl({required this._repository});

  final GlucoseInfusionRateRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteGlucoseInfusionRate(id);
}
