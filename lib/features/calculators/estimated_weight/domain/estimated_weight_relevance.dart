import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Estimated Weight: same
/// hospitalized-OR-confined-to-bed predicate as Adjusted Dry Weight (Slice
/// 10 po correction, 2026-09-26). Kept as its own function per this
/// codebase's near-identical-one-liner precedent.
bool isEstimatedWeightRelevant(CalculatorRelevanceContext context) =>
    context.hospitalized || context.confinedToBed;
