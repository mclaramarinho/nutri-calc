import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/repositories/enteral_nutrition_dripping_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteEnteralNutritionDrippingUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteEnteralNutritionDrippingUseCase)
class DeleteEnteralNutritionDrippingUseCaseImpl implements DeleteEnteralNutritionDrippingUseCase {
  const DeleteEnteralNutritionDrippingUseCaseImpl({required this._repository});

  final EnteralNutritionDrippingRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteEnteralNutritionDripping(id);
}
