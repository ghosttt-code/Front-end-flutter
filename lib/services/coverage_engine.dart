import 'dart:math';

import '../models/insurance_profile.dart';

class CoverageAssessment {
  final int incomeReplacementYears;
  final double incomeReplacement;
  final double debts;
  final double futureNeeds;
  final double existingCoverage;
  final double estimatedNeed;

  const CoverageAssessment({
    required this.incomeReplacementYears,
    required this.incomeReplacement,
    required this.debts,
    required this.futureNeeds,
    required this.existingCoverage,
    required this.estimatedNeed,
  });
}

class CoverageEngine {
  /// Backend-authoritative result: build an assessment directly from the Aura
  /// backend's figures (so the UI shows exactly what Aura calculated, not a
  /// re-derived local estimate). Years is taken from the backend profile.
  static CoverageAssessment fromBackend({
    required int years,
    required double incomeReplacement,
    required double debts,
    required double futureNeeds,
    required double existingCoverage,
    required double estimatedNeed,
  }) {
    return CoverageAssessment(
      incomeReplacementYears: years,
      incomeReplacement: incomeReplacement,
      debts: debts,
      futureNeeds: futureNeeds,
      existingCoverage: existingCoverage,
      estimatedNeed: estimatedNeed,
    );
  }

  /// Local fallback estimate, used only when no backend result is available
  /// (e.g. the results screen is opened directly without running a chat).
  static CoverageAssessment assess(InsuranceProfile profile) {
    final years = _replacementYears(profile.dependents);

    final incomeReplacement =
        profile.annualIncome * years;

    final estimatedNeed = max(
      0,
      incomeReplacement +
          profile.debts +
          profile.futureNeeds -
          profile.existingCoverage,
    ).toDouble();

    return CoverageAssessment(
      incomeReplacementYears: years,
      incomeReplacement: incomeReplacement,
      debts: profile.debts,
      futureNeeds: profile.futureNeeds,
      existingCoverage: profile.existingCoverage,
      estimatedNeed: estimatedNeed,
    );
  }

  static int _replacementYears(int dependents) {
    if (dependents <= 0) {
      return 5;
    }

    if (dependents <= 2) {
      return 8;
    }

    return 10;
  }
}