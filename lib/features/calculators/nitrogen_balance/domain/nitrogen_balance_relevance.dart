import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Nitrogen Balance:
/// "Hospitalized, Parenteral/Enteral nutrition, Confined to bed" - any one of
/// these conditions is enough to surface the calculator (OR, not AND): each
/// condition independently signals a patient whose nitrogen balance is
/// clinically relevant to track.
bool isNitrogenBalanceRelevant(CalculatorRelevanceContext context) =>
    context.hospitalized ||
    context.confinedToBed ||
    context.enteralNutrition ||
    context.parenteralNutrition;
