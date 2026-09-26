import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/data/models/nitrogen_balance_model.dart';

abstract class NitrogenBalanceRepository {
  Future<Result<NitrogenBalanceCalculationEntity, String>> createNitrogenBalance(
    NitrogenBalanceCalculationEntity nitrogenBalance,
  );

  Future<Result<List<NitrogenBalanceModel>, String>> getNitrogenBalances(String patientId);
  Future<Result<void, String>> deleteNitrogenBalance(String id);
}
