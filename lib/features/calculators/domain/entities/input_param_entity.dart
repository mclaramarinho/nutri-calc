/// A single parameter used in a calculator's computation, persisted
/// alongside the calculation result so the exact parameters that produced
/// it can be referenced later (roadmap section 3.1 "Calculators" storage
/// convention: every calculator table stores an `inputParams` JSON array of
/// `{ key, label, value }` entries).
///
/// `key` is a stable, language-independent identifier (e.g. "weight_kg")
/// that does not change with app locale. `label` is a user-facing display
/// label (may become an i18n key later, per roadmap priority 11).
///
/// `value` is typed `dynamic` rather than a fixed type: this entity is
/// shared across every future calculator type, and different
/// calculators/parameters carry different natural value types (numeric
/// weight/height, string-backed enum choices, boolean flags, etc.) — a fixed
/// type would force lossy stringification for some calculators. At the
/// persistence boundary (see `BmiModel`), the value is serialized as-is
/// into the `inputParams` JSON column and read back verbatim; no type
/// coercion happens at the domain layer.
class InputParamEntity {
  final String key;
  final String label;
  final dynamic value;

  const InputParamEntity({
    required this.key,
    required this.label,
    required this.value,
  });
}
