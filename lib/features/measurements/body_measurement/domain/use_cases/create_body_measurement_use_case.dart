import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/data/models/body_measurement_model.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/repositories/body_measurement_repository.dart';

abstract class CreateBodyMeasurementUseCase {
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    BodyMeasurementEntity entity,
  );
}

@Injectable(as: CreateBodyMeasurementUseCase)
class CreateBodyMeasurementUseCaseImpl implements CreateBodyMeasurementUseCase {
  const CreateBodyMeasurementUseCaseImpl({required this._repository});

  final BodyMeasurementRepository _repository;

  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    BodyMeasurementEntity entity,
  ) async {
    try {
      final data = await _repository.createMeasurement(
        BodyMeasurementModel(
          measurementType: entity.measurementType.toString(),
          createdAt: entity.createdAt,
          patientId: entity.patientId,
          value: entity.value,
        ),
      );

      if (data.isError) {
        return Error((data as Error).error);
      }

      return Ok(
        (data as Ok<List<BodyMeasurementModel>, String>).value
            .map(
              (el) => BodyMeasurementEntity(
                createdAt: el.createdAt,
                patientId: el.patientId,
                value: el.value,
                measurementType: BodyMeasurementTypeEnum.fromJson(
                  el.measurementType,
                ),
                id: el.id,
              ),
            )
            .toList(),
      );
    } catch (ex) {
      return Error("Error creating body measurement");
    }
  }
}
