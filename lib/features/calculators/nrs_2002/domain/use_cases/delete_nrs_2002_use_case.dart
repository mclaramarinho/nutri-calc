import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/repositories/nrs_2002_repository.dart';

/// One of the 14 leaf deletes dispatched by
/// `DeleteCalculatorHistoryEntryUseCase` (ADR 0010).
abstract class DeleteNrs2002UseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteNrs2002UseCase)
class DeleteNrs2002UseCaseImpl implements DeleteNrs2002UseCase {
  const DeleteNrs2002UseCaseImpl({required this._repository});

  final Nrs2002Repository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteNrs2002Calculation(id);
}
