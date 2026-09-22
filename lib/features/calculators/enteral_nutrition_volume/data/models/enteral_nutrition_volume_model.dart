import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';

part "enteral_nutrition_volume_model.g.dart";

@JsonSerializable()
class EnteralNutritionVolumeModel {
  final String id;
  final String patientId;
  final double value;
  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const EnteralNutritionVolumeModel({
    required this.id,
    required this.patientId,
    required this.value,
    required this.createdAt,
    required this.inputParams,
  });

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$EnteralNutritionVolumeModelToJson(this);

  factory EnteralNutritionVolumeModel.fromJson(Map<String, dynamic> json) =>
      _$EnteralNutritionVolumeModelFromJson(json);

  EnteralNutritionVolumeCalculationEntity toEntity() =>
      EnteralNutritionVolumeCalculationEntity(
        id: id,
        patientId: patientId,
        value: value,
        createdAt: createdAt,
        inputParams: inputParams,
      );

  factory EnteralNutritionVolumeModel.fromEntity(
    EnteralNutritionVolumeCalculationEntity entity, {
    String? id,
  }) => EnteralNutritionVolumeModel(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    value: entity.value,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
