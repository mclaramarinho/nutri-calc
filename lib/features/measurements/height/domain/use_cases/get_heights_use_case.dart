import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/data/models/height_model.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/repositories/height_repository.dart';

abstract class GetHeightsUseCase {
  Future<Result<List<HeightEntity>, String>> call(String patientId);
}

@Injectable(as: GetHeightsUseCase)
class GetHeightsUseCaseImpl implements GetHeightsUseCase {
  const GetHeightsUseCaseImpl({required this._repository});

  final HeightRepository _repository;

  @override
  Future<Result<List<HeightEntity>, String>> call(String patientId) async {
    try {
      final res = await _repository.getHeights(patientId);
      if (res.isOk) {
        final values = (res as Ok<List<HeightModel>, String>).value
            .map(
              (ht) => HeightEntity(
                createdAt: ht.createdAt,
                value: ht.value,
                patientId: ht.patientId,
                id: ht.id,
              ),
            )
            .toList();
        values.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
        return Ok(values);
      }

      return Error("Could not get heights for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
