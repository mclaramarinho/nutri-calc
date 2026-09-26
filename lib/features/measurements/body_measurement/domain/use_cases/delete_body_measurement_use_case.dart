import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/repositories/body_measurement_repository.dart';

abstract class DeleteBodyMeasurementUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteBodyMeasurementUseCase)
class DeleteBodyMeasurementUseCaseImpl implements DeleteBodyMeasurementUseCase {
  const DeleteBodyMeasurementUseCaseImpl({required this._repository});

  final BodyMeasurementRepository _repository;

  @override
  Future<Result<void, String>> call(String id) =>
      _repository.deleteMeasurement(id);
}
