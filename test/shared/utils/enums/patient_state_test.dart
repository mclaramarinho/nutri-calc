import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';

void main() {
  group('PatientState.label', () {
    test('every value maps to a non-empty PT-BR string', () {
      for (final state in PatientState.values) {
        expect(
          state.label,
          isNotEmpty,
          reason: 'label missing for $state',
        );
      }
    });

    test('labels match the approved PT-BR copy', () {
      expect(PatientState.healthy.label, 'Saudável / Manutenção');
      expect(PatientState.criticalStable.label, 'Paciente crítico (estável)');
      expect(PatientState.burn.label, 'Queimado');
      expect(PatientState.severeTrauma.label, 'Trauma grave');
      expect(
        PatientState.continousRenalReplacementTherapy.label,
        'Terapia renal substitutiva contínua (TRSC)',
      );
      expect(
        PatientState.renalInsufficiency.label,
        'Insuficiência renal (não dialítico)',
      );
      expect(
        PatientState.renalInsufficiencyWithDialysis.label,
        'Insuficiência renal (dialítico)',
      );
      expect(PatientState.neuroDamage.label, 'Dano neurológico (AVE/TCE)');
    });
  });
}
