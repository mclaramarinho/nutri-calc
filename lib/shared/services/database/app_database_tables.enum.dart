enum AppDatabaseTables {
  test(name: "TEST");

  final String name;
  const AppDatabaseTables({required this.name});

  String get sql {
    switch (this) {
      case .test:
        return '''
          CREATE TABLE IF NOT EXISTS $name 
          (id INTEGER PRIMARY KEY)
        ''';
    }
  }
}
