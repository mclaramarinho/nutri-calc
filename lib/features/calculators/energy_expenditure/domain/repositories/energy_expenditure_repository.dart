import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';

abstract class EnergyExpenditureRepository {
  Future<Result<EnergyExpenditureCalculationEntity, String>>
  createEnergyExpenditure(EnergyExpenditureCalculationEntity energyExpenditure);
}
