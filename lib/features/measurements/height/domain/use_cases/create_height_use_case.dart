import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/data/models/height_model.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/repositories/height_repository.dart';

abstract class CreateHeightUseCase {
  Future<Result<HeightEntity, String>> call({required HeightEntity height});
}

@Injectable(as: CreateHeightUseCase)
class CreateHeightUseCaseImpl implements CreateHeightUseCase {
  const CreateHeightUseCaseImpl({required this._repository});

  final HeightRepository _repository;

  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async {
    try {
      final res = await _repository.createHeight(
        value: height.value,
        patientId: height.patientId,
        createdAt: height.createdAt,
      );
      if (res.isOk) {
        final id = (res as Ok<HeightModel, String>).value.id;
        return Ok(height.copyWith(id: id));
      }
      return Error("Could not create height");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
