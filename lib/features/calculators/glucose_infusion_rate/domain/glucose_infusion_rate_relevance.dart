import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Glucose Infusion Rate
/// (TIG): relevant whenever the patient is on parenteral nutrition.
bool isGlucoseInfusionRateRelevant(CalculatorRelevanceContext context) =>
    context.parenteralNutrition;
