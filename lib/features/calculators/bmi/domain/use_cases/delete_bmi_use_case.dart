import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/repositories/bmi_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteBmiUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteBmiUseCase)
class DeleteBmiUseCaseImpl implements DeleteBmiUseCase {
  const DeleteBmiUseCaseImpl({required this._repository});

  final BmiRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteBmi(id);
}
