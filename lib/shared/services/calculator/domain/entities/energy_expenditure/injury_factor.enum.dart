enum InjuryFactor {
  aids(min: 1.1, max: 1.45),
  cancer(min: 1.1, max: 1.45),
  electiveSurgery(min: 1, max: 1.2),
  nonComplicatedMalnutrition(min: 0.8, max: 1),
  severeMalnutrition(min: 1.5, max: 1.5),
  diabetes(min: 1.1, max: 1.1),
  cardioLungDiseaseWithSepsis(min: 1.25, max: 1.25),
  cardioLungDiseaseNoSepsis(min: 0.9, max: 0.9),
  cardioLungDiseaseSurgery(min: 1.3, max: 1.55),
  dpoc(min: 1.2, max: 1.2),
  organFailure1to2(min: 1.4, max: 1.5),
  multipleFractures(min: 1.2, max: 1.35),
  infection(min: 1.1, max: 1.25),
  severeInfection(min: 1.3, max: 1.35),
  cardiacInsuficiency(min: 1.3, max: 1.5),
  liverInsuficiency(min: 1.3, max: 1.55),
  ira(min: 1.3, max: 1.3),
  chronicRenalDisease(min: 1.35, max: 1.35),
  nonComplicatedPatient(min: 0.85, max: 1),
  polytraumaWithSepsis(min: 1.6, max: 1.6),
  polytraumaRehab(min: 1.5, max: 1.5),
  neuro(min: 1.15, max: 1.2),
  coma(min: 1.15, max: 1.2),
  pancreatitis(min: 1.3, max: 1.8),
  smallSurgery(min: 1.2, max: 1.2),
  smallTissueTrauma(min: 1.14, max: 1.37),
  peritonitis(min: 1.2, max: 1.5),
  postOpcancer(min: 1.1, max: 1.4),
  postOpCardio(min: 1.2, max: 1.5),
  postOpElective(min: 1, max: 1.1),
  postOpGeneral(min: 1, max: 1.5),
  burnUpTo20(min: 1, max: 1.5),
  burn20To50(min: 1.7, max: 1.7),
  burn50To70(min: 1.8, max: 1.8),
  burn70To90(min: 2, max: 2),
  burn90To100(min: 2.1, max: 2.1),
  retocolitisOrCrohn(min: 1.3, max: 1.3),
  sepsis(min: 1.4, max: 1.8),
  respiratoryDistressSyndrome(min: 1.35, max: 1.35),
  shortIntestineSyndrome(min: 1.45, max: 1.45),
  boneMarrowTransplant(min: 1.2, max: 1.3),
  liverTransplant(min: 1.2, max: 1.5),
  traumaticBrainInjury(min: 1.4, max: 1.4),
  softTissueTrauma(min: 1.14, max: 1.37),
  traumaWithSepsis(min: 1.6, max: 1.6),
  boneTrauma(min: 1.35, max: 1.35);

  final double min;
  final double max;

  const InjuryFactor({required this.min, required this.max});
}
// Fonte: SBNPE; ASBRAN, 2011.
// https://www.gov.br/hubrasil/pt-br/hospitais-universitarios/regiao-centro-oeste/hc-ufg/comunicacao/noticias/unidade-de-nutricao-clinica-do-hc-lanca-protocolo-de-atendimento-nutricional/NutricaoProtocolo_Adulto.pdf
// Fonte: Avesani; Santos; Cuppari, 2002; Candelária; Rasslan, 2009.

// Fonte: JESUS, 2002; AUGUSTO et al., 1995. * Adaptado de SILBERMAN; ELISENBERG; GUERRA, 2002.