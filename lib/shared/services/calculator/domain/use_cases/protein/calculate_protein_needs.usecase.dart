// Adulto Saudável/Manutenção	0.8 - 1.0 g/kg
// Paciente Crítico (Estável)	1.2 - 1.5 g/kg
// Queimados/Trauma Grave/CRRT	1.5 - 2.0 g/kg
// Insuficiência Renal (Não dialítico)	0.6 - 0.8 g/kg
// Insuficiência Renal (Dialítico)	1.2 - 1.4 g/kg

// Nota sobre Danos Neurológicos (AVE/TCE):
// Frequentemente apresentam disfagia e risco de desnutrição. Considerar 1.2 - 1.5 g/kg para evitar sarcopenia e favorecer cicatrização.

// Referências:
// Weijs PJM, et al. Protein intake in critically ill patients. Curr Opin Clin Nutr Metab Care. 2014.
// Singer P, et al. ESPEN guideline: Clinical nutrition in the intensive care unit. Clin Nutr. 2019.

import 'package:nutri_calc/shared/services/calculator/domain/entities/protein/protein_needs.entity.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateProteinNeeds {
  Result<ProteinNeeds, String> call({
    required double weight,
    required PatientState patientState,
  }) {
    try {
      final needs = proteinNeedsPerState[patientState];
      if (needs == null) {
        throw "NO_PROTEIN_NEEDS_FOR_STATE";
      }
      return Ok(ProteinNeeds(min: needs.min * weight, max: needs.max * weight));
    } catch (err) {
      return Error(err.toString());
    }
  }
}

const Map<PatientState, ProteinNeeds> proteinNeedsPerState = {
  PatientState.healthy: ProteinNeeds(min: 0.8, max: 1),
  PatientState.criticalStable: ProteinNeeds(min: 1.5, max: 2),
  PatientState.renalInsufficiency: ProteinNeeds(min: 0.6, max: 0.8),
  PatientState.renalInsufficiencyWithDialysis: ProteinNeeds(min: 1.2, max: 1.4),
  PatientState.neuroDamage: ProteinNeeds(min: 1.2, max: 1.5),
  PatientState.burn: ProteinNeeds(min: 1.5, max: 2),
  PatientState.severeTrauma: ProteinNeeds(min: 1.5, max: 2),
  PatientState.continousRenalReplacementTherapy: ProteinNeeds(min: 1.5, max: 2),
};
