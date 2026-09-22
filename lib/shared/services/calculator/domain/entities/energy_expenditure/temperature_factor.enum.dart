enum TemperatureFactor {
  c38(val: 1.1),
  c39(val: 1.2),
  c40(val: 1.3),
  c41(val: 1.4);

  final double val;

  const TemperatureFactor({required this.val});

  String get label {
    switch (this) {
      case .c38:
        return "38°C";
      case .c39:
        return "39°C";
      case .c40:
        return "40°C";
      case .c41:
        return "41°C";
    }
  }
}
// Fonte: SBNPE; ASBRAN, 2011.
// https://www.gov.br/hubrasil/pt-br/hospitais-universitarios/regiao-centro-oeste/hc-ufg/comunicacao/noticias/unidade-de-nutricao-clinica-do-hc-lanca-protocolo-de-atendimento-nutricional/NutricaoProtocolo_Adulto.pdf
