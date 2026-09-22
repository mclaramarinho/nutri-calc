import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Enteral Nutrition Speed:
/// relevant whenever the patient is on enteral nutrition.
bool isEnteralNutritionSpeedRelevant(CalculatorRelevanceContext context) =>
    context.enteralNutrition;
