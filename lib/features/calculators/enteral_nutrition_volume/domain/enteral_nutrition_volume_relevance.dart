import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Enteral Nutrition Volume:
/// relevant whenever the patient is on enteral nutrition.
bool isEnteralNutritionVolumeRelevant(CalculatorRelevanceContext context) =>
    context.enteralNutrition;
