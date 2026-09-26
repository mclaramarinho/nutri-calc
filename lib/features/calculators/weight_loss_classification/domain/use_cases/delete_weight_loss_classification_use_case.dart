import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/repositories/weight_loss_classification_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteWeightLossClassificationUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteWeightLossClassificationUseCase)
class DeleteWeightLossClassificationUseCaseImpl implements DeleteWeightLossClassificationUseCase {
  const DeleteWeightLossClassificationUseCaseImpl({required this._repository});

  final WeightLossClassificationRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteWeightLossClassification(id);
}
