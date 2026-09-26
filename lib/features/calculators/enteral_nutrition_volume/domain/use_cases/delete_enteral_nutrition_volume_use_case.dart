import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/repositories/enteral_nutrition_volume_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteEnteralNutritionVolumeUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteEnteralNutritionVolumeUseCase)
class DeleteEnteralNutritionVolumeUseCaseImpl implements DeleteEnteralNutritionVolumeUseCase {
  const DeleteEnteralNutritionVolumeUseCaseImpl({required this._repository});

  final EnteralNutritionVolumeRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteEnteralNutritionVolume(id);
}
