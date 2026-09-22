import 'dart:convert';

import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// Shared `{key,label,value}`-array JSON encode/decode logic for the
/// `inputParams` column every calculator table persists (roadmap 3.1
/// storage convention, see [InputParamEntity]). Extracted so calculators
/// beyond BMI (e.g. Energy Expenditure) don't duplicate this logic in their
/// own model classes.
class InputParamsJsonCodec {
  const InputParamsJsonCodec._();

  static String toJson(List<InputParamEntity> value) => jsonEncode(
    value
        .map((p) => {"key": p.key, "label": p.label, "value": p.value})
        .toList(),
  );

  static List<InputParamEntity> fromJson(dynamic value) =>
      (jsonDecode(value as String) as List)
          .map(
            (e) => InputParamEntity(
              key: (e as Map<String, dynamic>)["key"] as String,
              label: e["label"] as String,
              value: e["value"],
            ),
          )
          .toList();
}
