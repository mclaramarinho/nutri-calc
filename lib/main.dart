import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/database/app_database.service.dart';

Future<void> main() async {
  configureDependencies();

  // Initialize database
  await getIt.get<AppDatabase>().init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
