import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// MUST is an adult/elderly screening tool - relevant only for patients
/// aged 19+. Same null-age idiom as the rest of the codebase's relevance
/// predicates (e.g. `isEnergyExpenditureRelevant`): a missing age is simply
/// not relevant, not defaulted to 0/999.
bool isMustRelevant(CalculatorRelevanceContext context) =>
    context.age != null && context.age! >= 19;
