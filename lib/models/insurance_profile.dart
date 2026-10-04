class InsuranceProfile {
  final String name;
  final int dependents;
  final double annualIncome;
  final double debts;
  final double futureNeeds;
  final double existingCoverage;

  const InsuranceProfile({
    required this.name,
    required this.dependents,
    required this.annualIncome,
    required this.debts,
    required this.futureNeeds,
    required this.existingCoverage,
  });

  factory InsuranceProfile.demo() {
    return const InsuranceProfile(
      name: 'Adam',
      dependents: 2,
      annualIncome: 75000,
      debts: 200000,
      futureNeeds: 100000,
      existingCoverage: 50000,
    );
  }

  InsuranceProfile copyWith({
    String? name,
    int? dependents,
    double? annualIncome,
    double? debts,
    double? futureNeeds,
    double? existingCoverage,
  }) {
    return InsuranceProfile(
      name: name ?? this.name,
      dependents: dependents ?? this.dependents,
      annualIncome: annualIncome ?? this.annualIncome,
      debts: debts ?? this.debts,
      futureNeeds: futureNeeds ?? this.futureNeeds,
      existingCoverage: existingCoverage ?? this.existingCoverage,
    );
  }
}