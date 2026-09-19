import 'package:flutter/material.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';

class CalculatorDefinition {
  final String id;
  final CalculatorType type;
  final String name;
  final IconData? icon;
  final bool Function(CalculatorRelevanceContext context) isRelevant;
  final void Function(BuildContext context) onTap;

  const CalculatorDefinition({
    required this.id,
    required this.type,
    required this.name,
    required this.isRelevant,
    required this.onTap,
    this.icon,
  });
}
