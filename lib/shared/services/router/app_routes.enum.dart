import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nutri_calc/features/home/presentation/home.page.dart';
import 'package:nutri_calc/features/patients/new/presentation/pages/new_patient.page.dart';

enum AppRoutes {
  createPatient(page: NewPatientPage(), path: "/create-patient"),
  home(page: HomePage(), path: "/");

  final String path;
  final Widget page;

  const AppRoutes({required this.path, required this.page});

  static AppRoutes? getByPath(String p) {
    try {
      return .values.firstWhere((r) => r.path == p);
    } catch (e) {
      return null;
    }
  }
}
