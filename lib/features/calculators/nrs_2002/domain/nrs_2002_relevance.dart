import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// NRS-2002 is an adult/elderly, hospitalized-patient screening tool -
/// relevant only for patients aged 19+ who are hospitalized. Same null-age
/// idiom as the rest of the codebase's relevance predicates.
bool isNrs2002Relevant(CalculatorRelevanceContext context) =>
    context.age != null && context.age! >= 19 && context.hospitalized;
