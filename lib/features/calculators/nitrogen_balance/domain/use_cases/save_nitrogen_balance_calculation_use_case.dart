import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/repositories/nitrogen_balance_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/nitrogen/calculate_nitrogen_balance.usecase.dart';

abstract class SaveNitrogenBalanceCalculationUseCase {
  Future<Result<NitrogenBalanceCalculationEntity, String>> call({
    required String patientId,
    required double ingestedProtein,
    required double urineNitrogen24h,
  });
}

@Injectable(as: SaveNitrogenBalanceCalculationUseCase)
class SaveNitrogenBalanceCalculationUseCaseImpl
    implements SaveNitrogenBalanceCalculationUseCase {
  const SaveNitrogenBalanceCalculationUseCaseImpl({required this._repository});

  final NitrogenBalanceRepository _repository;

  @override
  Future<Result<NitrogenBalanceCalculationEntity, String>> call({
    required String patientId,
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) async {
    try {
      final res = CalculateNitrogenBalance().call(
        ingestedProtein: ingestedProtein,
        urineNitrogen24h: urineNitrogen24h,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = NitrogenBalanceCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "ingested_protein",
            label: "Proteína Ingerida (g)",
            value: ingestedProtein,
          ),
          InputParamEntity(
            key: "urine_nitrogen_24h",
            label: "Nitrogênio Urinário 24h (g)",
            value: urineNitrogen24h,
          ),
        ],
      );

      return _repository.createNitrogenBalance(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
