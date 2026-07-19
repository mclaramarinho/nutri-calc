enum ActivityFactor {
  bedAndVentilator(val: 1.1),
  bed(val: 1.2),
  bedAndWalking(val: 1.25),
  walking(val: 1.3);

  final double val;

  const ActivityFactor({required this.val});
}
// Fonte: SBNPE; ASBRAN, 2011.
// https://www.gov.br/hubrasil/pt-br/hospitais-universitarios/regiao-centro-oeste/hc-ufg/comunicacao/noticias/unidade-de-nutricao-clinica-do-hc-lanca-protocolo-de-atendimento-nutricional/NutricaoProtocolo_Adulto.pdf
