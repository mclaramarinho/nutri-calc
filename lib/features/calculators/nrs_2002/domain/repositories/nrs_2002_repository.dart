import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/data/models/nrs_2002_model.dart';

abstract class Nrs2002Repository {
  Future<Result<Nrs2002CalculationEntity, String>> createNrs2002Calculation(
    Nrs2002CalculationEntity nrs2002,
  );

  Future<Result<List<Nrs2002Model>, String>> getNrs2002Calculations(String patientId);
  Future<Result<void, String>> deleteNrs2002Calculation(String id);
}
