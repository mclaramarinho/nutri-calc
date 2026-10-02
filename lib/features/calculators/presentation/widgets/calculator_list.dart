import 'package:flutter/material.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/filter_relevant_calculators_use_case.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';

class CalculatorList extends StatefulWidget {
  const CalculatorList({
    required this.definitions,
    required this.relevanceContext,
    super.key,
  });

  final List<CalculatorDefinition> definitions;
  final CalculatorRelevanceContext relevanceContext;

  @override
  State<CalculatorList> createState() => _CalculatorListState();
}

class _CalculatorListState extends State<CalculatorList> {
  bool _showAll = false;
  final _filter = const FilterRelevantCalculators();

  DsListTile _buildTile(CalculatorDefinition c) {
    return DsListTile(
      title: c.name,
      leading: c.icon != null ? Icon(c.icon) : null,
      onTap: () => c.onTap(context),
    );
  }

  Widget _buildRelevantView() {
    final relevant = _filter(widget.relevanceContext, widget.definitions);

    if (relevant.isEmpty) {
      return DsPlaceholder(
        message: "Nenhuma calculadora relevante no momento.",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: relevant.map(_buildTile).toList(),
    );
  }

  Widget _buildAllView() {
    final groups = <Widget>[];

    for (final type in CalculatorType.values) {
      final definitionsForType = widget.definitions
          .where((c) => c.type == type)
          .toList();

      if (definitionsForType.isEmpty) continue;

      if (definitionsForType.length > 1) {
        groups.add(
          Text(type.label, style: DsTextStyles.sectionHeader(context)),
        );
        groups.add(SizedBox(height: DsSpacing.sm));
      }
      groups.addAll(definitionsForType.map(_buildTile));
      groups.add(SizedBox(height: DsSpacing.vLg));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groups,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.sm,
        children: [
          _showAll ? _buildAllView() : _buildRelevantView(),
          DsButton(
            label: _showAll
                ? "Ver apenas relevantes"
                : "Ver todas as calculadoras",
            isLoading: false,
            onTap: () => setState(() => _showAll = !_showAll),
          ),
        ],
      ),
    );
  }
}
