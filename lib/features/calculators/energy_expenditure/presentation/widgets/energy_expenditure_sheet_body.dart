import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer_pocket.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/harris_bennedict/calculate_eer_harris_benedict.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/mifflin/calculate_eer_mifflin.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/pocket/calculate_eer_pocket.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/schofield/calculate_eer_schofield_wh.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/who/calculate_eer_who.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// The gathered inputs + computed range confirmed from the Energy
/// Expenditure sheet, popped whole via `AppRouter.pop` on "Confirmar" (see
/// DECISION 2) so the tab can read everything back directly without extra
/// state-holder plumbing.
typedef GatheredEnergyExpenditureInputs = ({
  EnergyExpenditureFormulaEnum formula,
  Gender? gender,
  ActivityFactor? activityFactor,
  InjuryFactor? injuryFactor,
  TemperatureFactor? temperatureFactor,
  StressLevel stressLevel,
  double minValue,
  double maxValue,
});

class EnergyExpenditureSheetBody extends StatefulWidget {
  const EnergyExpenditureSheetBody({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    super.key,
  });

  final double weightKg;
  final double? heightCm;
  final int? age;

  @override
  State<EnergyExpenditureSheetBody> createState() =>
      _EnergyExpenditureSheetBodyState();
}

class _EnergyExpenditureSheetBodyState
    extends State<EnergyExpenditureSheetBody> {
  int _step = 1;

  EnergyExpenditureFormulaEnum? _formula;
  Gender? _gender;
  ActivityFactor? _activityFactor;
  InjuryFactor? _injuryFactor;
  TemperatureFactor? _temperatureFactor;
  StressLevel _stressLevel = StressLevel.noStress;

  String? _calcErrorMessage;
  double? _minValue;
  double? _maxValue;

  bool get _isPocket => _formula == .pocket;
  bool get _needsHeight =>
      _formula == .harrisBenedict ||
      _formula == .mifflin ||
      _formula == .schofield;
  // Currently identical: every non-pocket formula needs both age and
  // gender/activity. Modeled as separate getters since they answer distinct
  // questions and a future formula could need one without the other.
  bool get _needsAge => _formula != null && _formula != .pocket;
  bool get _needsGenderAndActivity => _formula != null && _formula != .pocket;

  String? get _validationMessage {
    if (_formula == null) return "Selecione uma fórmula.";

    if (_needsHeight && widget.heightCm == null) {
      return "Cadastre uma altura para essa fórmula.";
    }

    if (_needsAge && widget.age == null) {
      return "Cadastre a idade do paciente para essa fórmula.";
    }

    if (_formula == .schofield &&
        widget.age != null &&
        widget.age! > CalculateEerSchofield.maxAge) {
      return "Schofield é válido apenas para pacientes de até "
          "${CalculateEerSchofield.maxAge} anos.";
    }

    if (_formula == .who &&
        widget.age != null &&
        widget.age! > CalculateEerWho.maxAge) {
      return "OMS é válido apenas para pacientes de até "
          "${CalculateEerWho.maxAge} anos.";
    }

    if (_needsGenderAndActivity &&
        (_gender == null || _activityFactor == null)) {
      return "Selecione o sexo e o fator de atividade.";
    }

    return null;
  }

  String _friendlyCalcError(String error) {
    switch (error) {
      case "INVALID_AGE":
        return "Idade inválida para essa fórmula.";
      case "INVALID_PARAMS":
        return "Parâmetros inválidos para essa fórmula.";
      default:
        return "Não foi possível calcular o gasto energético.";
    }
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    Result<Object, String> res;

    switch (_formula!) {
      case .harrisBenedict:
        res = CalculateEerHarrisBenedict().call(
          gender: _gender!,
          weight: widget.weightKg,
          height: widget.heightCm!,
          age: widget.age!,
          activityFactor: _activityFactor!,
          injuryFactor: _injuryFactor,
          temperatureFactor: _temperatureFactor,
        );
        break;
      case .mifflin:
        res = CalculateEerMifflin().call(
          gender: _gender!,
          weight: widget.weightKg,
          height: widget.heightCm!,
          age: widget.age!,
          activityFactor: _activityFactor!,
          injuryFactor: _injuryFactor,
          temperatureFactor: _temperatureFactor,
        );
        break;
      case .schofield:
        res = CalculateEerSchofield().call(
          weight: widget.weightKg,
          height: widget.heightCm!,
          age: widget.age!,
          gender: _gender!,
          activityFactor: _activityFactor!,
          injuryFactor: _injuryFactor,
          temperatureFactor: _temperatureFactor,
        );
        break;
      case .who:
        res = CalculateEerWho().call(
          weight: widget.weightKg,
          age: widget.age!,
          gender: _gender!,
          activityFactor: _activityFactor!,
          injuryFactor: _injuryFactor,
          temperatureFactor: _temperatureFactor,
        );
        break;
      case .pocket:
        res = CalculateEerPocket().call(
          weight: widget.weightKg,
          stressLevel: _stressLevel,
        );
        break;
    }

    if (res.isError) {
      setState(() {
        _calcErrorMessage = _friendlyCalcError(
          (res as Error<Object, String>).error,
        );
      });
      return;
    }

    final value = (res as Ok<Object, String>).value;
    final double min;
    final double max;
    if (value is EER) {
      min = value.minEer;
      max = value.maxEer;
    } else {
      final pocket = value as EERPocket;
      min = pocket.min;
      max = pocket.max;
    }

    setState(() {
      _calcErrorMessage = null;
      _minValue = min;
      _maxValue = max;
      _step = 2;
    });
  }

  String _rangeLabel(double min, double max) {
    if (min == max) return "${min.toStringAsFixed(0)} kcal/dia";
    return "${min.toStringAsFixed(0)} – ${max.toStringAsFixed(0)} kcal/dia";
  }

  List<DropdownMenuEntry<InjuryFactor?>> get _injuryFactorOptions => [
    DropdownMenuEntry(value: null, label: "Nenhum"),
    ...InjuryFactor.values.map(
      (f) => DropdownMenuEntry(value: f, label: f.label),
    ),
  ];

  List<DropdownMenuEntry<TemperatureFactor?>> get _temperatureFactorOptions => [
    DropdownMenuEntry(value: null, label: "Nenhum"),
    ...TemperatureFactor.values.map(
      (f) => DropdownMenuEntry(value: f, label: f.label),
    ),
  ];

  Widget _buildStep1() {
    final validation = _validationMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DsSpacing.sm,
      children: [
        Text(
          "Configurar cálculo",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        DsSelect<EnergyExpenditureFormulaEnum>(
          label: "Fórmula",
          dropdownOptions: EnergyExpenditureFormulaEnum.values
              .map((f) => DropdownMenuEntry(value: f, label: f.label))
              .toList(),
          onDropdownSelect: (value) => setState(() {
            _formula = value;
            _calcErrorMessage = null;
          }),
        ),
        Text("Peso: ${widget.weightKg} kg"),
        if (_needsHeight) ...[
          if (widget.heightCm != null)
            Text("Altura: ${widget.heightCm} cm")
          else
            Text(
              "Cadastre uma altura para essa fórmula.",
              style: TextStyle(color: DsColors.of(context).error),
            ),
        ],
        if (_needsAge) ...[
          if (widget.age != null)
            Text("Idade: ${widget.age}")
          else
            Text(
              "Cadastre a idade do paciente para essa fórmula.",
              style: TextStyle(color: DsColors.of(context).error),
            ),
        ],
        if (_needsGenderAndActivity) ...[
          DsSelect<Gender>(
            label: "Sexo",
            dropdownOptions: [
              DropdownMenuEntry(value: Gender.male, label: "Masculino"),
              DropdownMenuEntry(value: Gender.female, label: "Feminino"),
            ],
            onDropdownSelect: (value) => setState(() => _gender = value),
          ),
          DsSelect<ActivityFactor>(
            label: "Fator de Atividade",
            dropdownOptions: ActivityFactor.values
                .map((f) => DropdownMenuEntry(value: f, label: f.label))
                .toList(),
            onDropdownSelect: (value) =>
                setState(() => _activityFactor = value),
          ),
          DsSelect<InjuryFactor?>(
            label: "Fator de Injúria",
            dropdownOptions: _injuryFactorOptions,
            onDropdownSelect: (value) => setState(() => _injuryFactor = value),
          ),
          DsSelect<TemperatureFactor?>(
            label: "Fator de Temperatura",
            dropdownOptions: _temperatureFactorOptions,
            onDropdownSelect: (value) =>
                setState(() => _temperatureFactor = value),
          ),
        ],
        if (_isPocket) ...[
          DsSelect<StressLevel>(
            label: "Nível de Estresse",
            dropdownOptions: StressLevel.values
                .map((s) => DropdownMenuEntry(value: s, label: s.label))
                .toList(),
            onDropdownSelect: (value) =>
                setState(() => _stressLevel = value ?? StressLevel.noStress),
          ),
        ],
        if (_calcErrorMessage != null)
          Text(
            _calcErrorMessage!,
            style: TextStyle(color: DsColors.of(context).error),
          ),
        SizedBox(height: DsSpacing.sm),
        DsButton(
          label: "Calcular",
          isLoading: false,
          disabled: validation != null,
          onTap: _calculate,
        ),
        if (validation != null)
          Padding(
            padding: EdgeInsets.only(top: DsSpacing.xs),
            child: Text(
              validation,
              style: TextStyle(color: DsColors.of(context).error),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DsSpacing.sm,
      children: [
        Text(
          "Confirmar resultado",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text("Fórmula: ${_formula!.label}"),
        Text("Peso: ${widget.weightKg} kg"),
        if (_needsHeight) Text("Altura: ${widget.heightCm} cm"),
        if (_needsAge) Text("Idade: ${widget.age}"),
        if (_needsGenderAndActivity) ...[
          Text("Sexo: ${_gender == .male ? 'Masculino' : 'Feminino'}"),
          Text("Fator de Atividade: ${_activityFactor?.label}"),
          if (_injuryFactor != null)
            Text("Fator de Injúria: ${_injuryFactor!.label}"),
          if (_temperatureFactor != null)
            Text("Fator de Temperatura: ${_temperatureFactor!.label}"),
        ],
        if (_isPocket) Text("Nível de Estresse: ${_stressLevel.label}"),
        SizedBox(height: DsSpacing.sm),
        Text(
          "Gasto Energético: ${_rangeLabel(_minValue!, _maxValue!)}",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.md,
      children: [
        _step == 1 ? _buildStep1() : _buildStep2(),
        if (_step == 2) ...[
          const Divider(),
          Row(
            spacing: DsSpacing.sm,
            children: [
              Expanded(
                child: DsButton(
                  label: "Cancelar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEnergyExpenditureInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEnergyExpenditureInputs?>((
                        formula: _formula!,
                        gender: _gender,
                        activityFactor: _activityFactor,
                        injuryFactor: _injuryFactor,
                        temperatureFactor: _temperatureFactor,
                        stressLevel: _stressLevel,
                        minValue: _minValue!,
                        maxValue: _maxValue!,
                      )),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
