import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

/// OPEN PO JUDGMENT CALL - not a settled requirement: roadmap 3.1's
/// Calculator Relevance table has no row at all for Water Needs. Treating
/// silence as "universally applicable" (always relevant) rather than
/// "deliberately excluded" is a PO inference made for this slice so the
/// calculator is reachable, not a confirmed product decision. Flagged here
/// for product to revisit explicitly - do not "clean up" this comment or
/// treat it as settled without that revisit.
bool isWaterNeedsRelevant(CalculatorRelevanceContext context) => true;
