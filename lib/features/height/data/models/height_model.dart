import 'package:json_annotation/json_annotation.dart';
part "height_model.g.dart";

@JsonSerializable()
class HeightModel {
  final String? id;
  final double value;
  final DateTime createdAt;
  final String patientId;

  const HeightModel({
    required this.value,
    required this.createdAt,
    required this.patientId,
    this.id,
  });

  Map<String, dynamic> toJson() => _$HeightModelToJson(this);

  factory HeightModel.fromJson(Map<String, dynamic> json) =>
      _$HeightModelFromJson(json);
}
