import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';

abstract class CreateWeightUseCase {
  Future<Result<WeightEntity, String>> call({required WeightEntity weight});
}

@Injectable(as: CreateWeightUseCase)
class CreateWeightUseCaseImpl implements CreateWeightUseCase {
  const CreateWeightUseCaseImpl({required this._repository});

  final WeightRepository _repository;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    try {
      final res = await _repository.createWeight(
        value: weight.value,
        patientId: weight.patientId,
        considerForCalculations: weight.considerForCalculations,
        weightType: weight.weightType,
        inputParams: weight.inputParams,
      );
      // `res.isOk` guards the cast below; using `.value` off the raw
      // `Result` (or casting to a generics-erased `Ok`) previously threw
      // `NoSuchMethodError`/produced a bogus `>=` check on every successful
      // create — fixed to check `isOk` and use the typed `Ok`'s `.value`.
      if (res.isOk) {
        final id = (res as Ok<WeightModel, String>).value.id;
        return Ok(weight.copyWith(id: id));
      }
      return Error("Could not create weight");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
