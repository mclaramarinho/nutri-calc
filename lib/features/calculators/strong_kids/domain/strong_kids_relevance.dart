import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// STRONG-Kids is a pediatric screening tool - relevant only for patients
/// under 19. Same null-age idiom as the rest of the codebase's relevance
/// predicates (e.g. `isEnergyExpenditureRelevant`): a missing age is simply
/// not relevant, not defaulted to 0/999.
bool isStrongKidsRelevant(CalculatorRelevanceContext context) =>
    context.age != null && context.age! < 19;
