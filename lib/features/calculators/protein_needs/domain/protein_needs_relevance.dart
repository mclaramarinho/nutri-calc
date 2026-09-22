import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Roadmap 3.1 Calculator Relevance table: Protein Needs is marked "Always
/// Relevant" - kept as a named function (rather than inlined `true`) for
/// consistency with every other calculator's relevance predicate shape.
bool isProteinNeedsRelevant(CalculatorRelevanceContext context) => true;
