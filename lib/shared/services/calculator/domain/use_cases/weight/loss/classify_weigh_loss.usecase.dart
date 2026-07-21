// Fonte: adaptada de Blackburn et al., 1977 8
// TODO - validar criteriosamente a logica de selecao de tempo de referencia para classificacao

import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_reference.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class ClassifyWeighLoss {
  const ClassifyWeighLoss();

  Result<WeightLoss, String> call({
    required double currentWeight,
    required double lastWeight,
    required DateTime lastWeightDate,
    required DateTime currentWeightDate,
  }) {
    try {
      if (currentWeight < 0 || lastWeight < 0) {
        return Error("INVALID_PARAMS");
      }

      final lost = lastWeight - currentWeight;
      final percentLost = (lost * 100) / lastWeight;

      final timeDiff = currentWeightDate.difference(lastWeightDate).inDays;

      final marks = WeightLossReference.allTimesInDays;

      if (timeDiff >= marks.last * 2) {
        return Ok(
          WeightLoss(
            percentage: percentLost,
            timeReference: WeightLossReference.none.timeInDays,
            classification: WeightLossClassification.ok,
          ),
        );
      }

      int valRef = -100;

      for (int i = 0; i < marks.length; i++) {
        final current = marks[i];

        if (i == marks.length - 1) {
          valRef = current;
          break;
        }

        final next = marks[i + 1];

        final diffCurr = (current - timeDiff).abs();
        final diffNext = (next - timeDiff).abs();

        if (diffCurr <= diffNext) {
          valRef = current;
          break;
        }
      }
      final timeReference = WeightLossReference.getByTimeInDays(valRef);
      final WeightLossClassification classification =
          percentLost > timeReference.severe
          ? .severe
          : percentLost >= timeReference.significative
          ? .significant
          : .ok;
      return Ok(
        WeightLoss(
          percentage: percentLost,
          timeReference: valRef,
          classification: classification,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}

void main() {
  final today = DateTime(2026, 7, 21);

  final tests = [2, 8, 15, 25, 30, 35, 45, 89, 90, 91, 180, 182, 270, 500];
  final expect = [7, 7, 7, 30, 30, 30, 30, 90, 90, 90, 180, 180, 180, -2000];

  for (int i = 0; i < tests.length; i++) {
    final res = ClassifyWeighLoss().call(
      currentWeight: 50,
      lastWeight: 55,
      lastWeightDate: today.subtract(Duration(days: tests[i])),
      currentWeightDate: today,
    );
    print("Day difference: ${tests[i]}");
    print("Expected: ${expect[i]}");

    res.when(
      ok: (val) => print(
        "Result: ${val.timeReference} days - ${val.classification}\n\n${val.timeReference == expect[i] ? 'Passed' : 'Failed'}!",
      ),
      error: (error) => print("Error executing: $error"),
    );

    print("========================================");
  }
}
