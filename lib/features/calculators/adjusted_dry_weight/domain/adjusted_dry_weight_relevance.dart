import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Adjusted Dry Weight: a
/// distinct, narrower override from Adequation/Adjusted Obesity's BMI-gated
/// predicate - this one is clinically tied to hospitalized/bedridden
/// fluid-overload patients (its formula subtracts oedema/ascites
/// adjustments), not BMI (Slice 10 po correction, 2026-09-26). Same
/// OR-shape precedent as Nitrogen Balance's multi-flag OR. May literally be
/// the same body as `isEstimatedWeightRelevant`, kept as its own function
/// per this codebase's near-identical-one-liner precedent.
bool isAdjustedDryWeightRelevant(CalculatorRelevanceContext context) =>
    context.hospitalized || context.confinedToBed;
