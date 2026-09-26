import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/repositories/enteral_nutrition_speed_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteEnteralNutritionSpeedUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteEnteralNutritionSpeedUseCase)
class DeleteEnteralNutritionSpeedUseCaseImpl implements DeleteEnteralNutritionSpeedUseCase {
  const DeleteEnteralNutritionSpeedUseCaseImpl({required this._repository});

  final EnteralNutritionSpeedRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteEnteralNutritionSpeed(id);
}
