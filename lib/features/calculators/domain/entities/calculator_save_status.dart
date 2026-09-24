import 'package:equatable/equatable.dart';

/// Represents the save lifecycle of a single calculator in the patient
/// details "Calculadoras" tab, mirroring the `Result<T, E>` idiom
/// (`lib/core/utils/result/result.dart`): an abstract base distinguished via
/// `is`-checks rather than a bools-bag (`isSaving`/`isXSaveError`/`isXSaved`).
sealed class CalculatorSaveStatus extends Equatable {
  const CalculatorSaveStatus();

  bool get isSaving => this is CalculatorSaveStatusSaving;
  bool get isError => this is CalculatorSaveStatusError;
  bool get isSaved => this is CalculatorSaveStatusSaved;

  String? get errorMessage => this is CalculatorSaveStatusError
      ? (this as CalculatorSaveStatusError).message
      : null;

  String? get savedMessage => this is CalculatorSaveStatusSaved
      ? (this as CalculatorSaveStatusSaved).message
      : null;
}

class CalculatorSaveStatusIdle extends CalculatorSaveStatus {
  const CalculatorSaveStatusIdle();

  @override
  List<Object?> get props => [];
}

class CalculatorSaveStatusSaving extends CalculatorSaveStatus {
  const CalculatorSaveStatusSaving();

  @override
  List<Object?> get props => [];
}

class CalculatorSaveStatusError extends CalculatorSaveStatus {
  const CalculatorSaveStatusError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CalculatorSaveStatusSaved extends CalculatorSaveStatus {
  const CalculatorSaveStatusSaved(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
