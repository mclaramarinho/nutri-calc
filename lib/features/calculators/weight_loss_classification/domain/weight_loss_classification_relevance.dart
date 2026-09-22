import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Relevant whenever the patient has at least 2 registered weights and the
/// most recent one (index 0, newest-first per §0's fixed sort) is strictly
/// lower than the previous one (index 1) - i.e. there was an actual weight
/// decrease between the two most recent measurements. Ties or an increase
/// are not relevant.
bool isWeightLossClassificationRelevant(CalculatorRelevanceContext context) =>
    context.weights.length >= 2 &&
    context.weights[0].value < context.weights[1].value;
