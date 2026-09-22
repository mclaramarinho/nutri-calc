import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Same raw-age-as-years interpretation used across this codebase's
/// relevance predicates (`age` is read as a plain number regardless of
/// `ageUnit`) — known pre-existing tech debt (roadmap 3.1 Calculator
/// Relevance table note), not addressed here to avoid a one-place-only fix.
bool isEnergyExpenditureRelevant(CalculatorRelevanceContext context) =>
    context.age != null && (context.hospitalized || context.confinedToBed);
