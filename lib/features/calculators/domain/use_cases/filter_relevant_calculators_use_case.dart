import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// Filters [CalculatorDefinition]s down to the ones relevant for a given
/// [CalculatorRelevanceContext].
///
/// Intentionally NOT DI-injected or interface-backed like the other use
/// cases in this codebase: it's a pure, synchronous function with no
/// dependencies and no failure mode, so the `abstract interface + @Injectable
/// Impl` ceremony would add nothing. Same rationale as the plain calculator
/// classes under `lib/shared/services/calculator/domain/use_cases/` (see
/// CLAUDE.md's "Domain calculators" section).
class FilterRelevantCalculators {
  const FilterRelevantCalculators();

  List<CalculatorDefinition> call(
    CalculatorRelevanceContext context,
    List<CalculatorDefinition> all,
  ) => all.where((c) => c.isRelevant(context)).toList();
}
