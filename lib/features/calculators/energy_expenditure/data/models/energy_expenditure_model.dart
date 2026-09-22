import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';

part "energy_expenditure_model.g.dart";

@JsonSerializable()
class EnergyExpenditureModel {
  final String id;
  final String patientId;

  @JsonKey(toJson: _formulaToJson, fromJson: _formulaFromJson)
  final EnergyExpenditureFormulaEnum formula;

  final double minValue;
  final double maxValue;
  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const EnergyExpenditureModel({
    required this.id,
    required this.patientId,
    required this.formula,
    required this.minValue,
    required this.maxValue,
    required this.createdAt,
    required this.inputParams,
  });

  static String _formulaToJson(EnergyExpenditureFormulaEnum value) =>
      value.name;
  static EnergyExpenditureFormulaEnum _formulaFromJson(dynamic value) =>
      EnergyExpenditureFormulaEnum.values.byName(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$EnergyExpenditureModelToJson(this);

  factory EnergyExpenditureModel.fromJson(Map<String, dynamic> json) =>
      _$EnergyExpenditureModelFromJson(json);

  EnergyExpenditureCalculationEntity toEntity() =>
      EnergyExpenditureCalculationEntity(
        id: id,
        patientId: patientId,
        formula: formula,
        minValue: minValue,
        maxValue: maxValue,
        createdAt: createdAt,
        inputParams: inputParams,
      );

  factory EnergyExpenditureModel.fromEntity(
    EnergyExpenditureCalculationEntity entity, {
    String? id,
  }) => EnergyExpenditureModel(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    formula: entity.formula,
    minValue: entity.minValue,
    maxValue: entity.maxValue,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
