import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table row for Enteral Nutrition Dripping:
/// relevant whenever the patient is on enteral nutrition.
bool isEnteralNutritionDrippingRelevant(CalculatorRelevanceContext context) =>
    context.enteralNutrition;
