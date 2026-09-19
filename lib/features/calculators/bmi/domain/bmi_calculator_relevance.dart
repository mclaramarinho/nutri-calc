import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Deliberately reuses the same raw-age-as-years interpretation
/// CalculateBmi/PatientDetailsCubit._computeBmi already use - known
/// pre-existing tech debt (roadmap 3.1 Calculator Relevance table note),
/// not "fixed" here to avoid a one-place-only inconsistency.
bool isBmiRelevant(CalculatorRelevanceContext context) =>
    context.age != null && context.age! >= 19;
