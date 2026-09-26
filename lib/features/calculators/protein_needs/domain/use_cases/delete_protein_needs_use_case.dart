import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/repositories/protein_needs_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteProteinNeedsUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteProteinNeedsUseCase)
class DeleteProteinNeedsUseCaseImpl implements DeleteProteinNeedsUseCase {
  const DeleteProteinNeedsUseCaseImpl({required this._repository});

  final ProteinNeedsRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteProteinNeeds(id);
}
