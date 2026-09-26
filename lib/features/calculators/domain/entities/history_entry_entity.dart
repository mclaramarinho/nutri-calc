import 'package:equatable/equatable.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// The common shape every one of the 14 history sources is normalized to
/// (ADR 0009), so `PatientHistoryTab` can group/render a single flat list
/// regardless of which underlying table a row came from.
class HistoryEntryEntity extends Equatable {
  final String id;
  final String patientId;
  final CalculatorType type;
  final HistorySourceType sourceType;
  final String label;
  final String resultSummary;
  final List<InputParamEntity> inputParams;
  final DateTime createdAt;

  const HistoryEntryEntity({
    required this.id,
    required this.patientId,
    required this.type,
    required this.sourceType,
    required this.label,
    required this.resultSummary,
    required this.inputParams,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    patientId,
    type,
    sourceType,
    label,
    resultSummary,
    inputParams,
    createdAt,
  ];
}
