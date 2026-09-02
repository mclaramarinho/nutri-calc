import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/data/models/body_measurement_model.dart';

abstract class BodyMeasurementRepository {
  Future<Result<List<BodyMeasurementModel>, String>> getMeasurements(String patientId);
  Future<Result<BodyMeasurementModel, String>> createMeasurement(BodyMeasurementModel model);
}