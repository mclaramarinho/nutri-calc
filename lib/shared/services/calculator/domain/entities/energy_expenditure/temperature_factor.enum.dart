enum TemperatureFactor {
  c38(val: 1.1),
  c39(val: 1.2),
  c40(val: 1.3),
  c41(val: 1.4);

  final double val;

  const TemperatureFactor({required this.val});
}
// Fonte: SBNPE; ASBRAN, 2011.
// https://www.gov.br/hubrasil/pt-br/hospitais-universitarios/regiao-centro-oeste/hc-ufg/comunicacao/noticias/unidade-de-nutricao-clinica-do-hc-lanca-protocolo-de-atendimento-nutricional/NutricaoProtocolo_Adulto.pdf
