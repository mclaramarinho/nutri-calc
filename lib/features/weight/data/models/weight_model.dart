import 'package:json_annotation/json_annotation.dart';
part "weight_model.g.dart";

@JsonSerializable()
class WeightModel {
  final String? id;
  final double value;
  final DateTime createdAt;
  final String patientId;

  const WeightModel({
    required this.value,
    required this.createdAt,
    required this.patientId,
    this.id,
  });

  Map<String, dynamic> toJson() => _$WeightModelToJson(this);

  factory WeightModel.fromJson(Map<String, dynamic> json) =>
      _$WeightModelFromJson(json);
}
