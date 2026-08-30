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
      );
      if (res.isOk && (res as Ok).value >= 1) {
        return Ok(weight.copyWith(id: ((res as Ok).value as WeightModel).id));
      }
      return Error("Could not create weight");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
