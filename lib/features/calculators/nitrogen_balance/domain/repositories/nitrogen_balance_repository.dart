import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';

abstract class NitrogenBalanceRepository {
  Future<Result<NitrogenBalanceCalculationEntity, String>> createNitrogenBalance(
    NitrogenBalanceCalculationEntity nitrogenBalance,
  );
}
