import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';

/// Resolves the weight to use for calculations out of a patient's weight
/// history: the first entry (in list order) with `considerForCalculations ==
/// true`, or `null` if none.
///
/// Intentionally NOT DI-injected or interface-backed, mirroring
/// `FilterRelevantCalculators`'s plain-class convention: it's a pure,
/// synchronous function with no dependencies and no failure mode, so the
/// `abstract interface + @Injectable Impl` ceremony would add nothing.
///
/// Precondition: [weights] is already ordered newest-first (the ordering
/// `GetWeightsUseCase` already guarantees). This function does NOT re-sort
/// defensively - every real call site already receives this ordering, and a
/// second, possibly-diverging sort policy here was rejected as unnecessary
/// complexity/perf cost (see ADR 0007). Garbage-in/garbage-out if a caller
/// violates the precondition - not this function's job to guard against.
class ResolveWeightForCalculations {
  const ResolveWeightForCalculations();

  WeightEntity? call(List<WeightEntity> weights) {
    for (final w in weights) {
      if (w.considerForCalculations) return w;
    }
    return null;
  }
}
