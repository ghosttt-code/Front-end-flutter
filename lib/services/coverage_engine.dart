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