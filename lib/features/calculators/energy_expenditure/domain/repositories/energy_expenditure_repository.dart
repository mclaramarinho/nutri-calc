import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/data/models/energy_expenditure_model.dart';

abstract class EnergyExpenditureRepository {
  Future<Result<EnergyExpenditureCalculationEntity, String>>
  createEnergyExpenditure(EnergyExpenditureCalculationEntity energyExpenditure);

  Future<Result<List<EnergyExpenditureModel>, String>> getEnergyExpenditures(String patientId);
  Future<Result<void, String>> deleteEnergyExpenditure(String id);
}
