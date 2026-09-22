enum PatientState {
  healthy,
  criticalStable,
  burn,
  severeTrauma,
  continousRenalReplacementTherapy, // CRRT
  renalInsufficiency,
  renalInsufficiencyWithDialysis,
  neuroDamage // AVE/TCE
  ;

  String get label {
    switch (this) {
      case .healthy:
        return "Saudável / Manutenção";
      case .criticalStable:
        return "Paciente crítico (estável)";
      case .burn:
        return "Queimado";
      case .severeTrauma:
        return "Trauma grave";
      case .continousRenalReplacementTherapy:
        return "Terapia renal substitutiva contínua (TRSC)";
      case .renalInsufficiency:
        return "Insuficiência renal (não dialítico)";
      case .renalInsufficiencyWithDialysis:
        return "Insuficiência renal (dialítico)";
      case .neuroDamage:
        return "Dano neurológico (AVE/TCE)";
    }
  }
}
