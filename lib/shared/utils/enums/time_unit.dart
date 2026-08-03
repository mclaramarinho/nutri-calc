enum TimeUnit {
  day(value: "Dia(s)"),
  month(value: "Mês(ses)"),
  year(value: "Ano(s)");

  final String value;
  const TimeUnit({required this.value});
}
