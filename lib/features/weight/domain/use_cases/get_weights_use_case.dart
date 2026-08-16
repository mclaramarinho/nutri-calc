import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/weight/domain/repositories/weight_repository.dart';

abstract class GetWeightsUseCase {
  Future<Result<List<WeightEntity>, String>> call(String patientId);
}

@Injectable(as: GetWeightsUseCase)
class GetWeightsUseCaseImpl implements GetWeightsUseCase {
  const GetWeightsUseCaseImpl({required this._repository});

  final WeightRepository _repository;

  @override
  Future<Result<List<WeightEntity>, String>> call(String patientId) async {
    try {
      final res = await _repository.getWeights(patientId);
      if (res.isOk) {
        final values = (res as Ok<List<WeightModel>, String>).value
            .map(
              (wt) => WeightEntity(
                createdAt: wt.createdAt,
                value: wt.value,
                patientId: wt.patientId,
                id: wt.id,
              ),
            )
            .toList();
        values.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
        return Ok(values);
      }

      return Error("Could not get weights for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
