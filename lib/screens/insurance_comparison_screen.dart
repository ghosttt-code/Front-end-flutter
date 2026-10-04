import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../services/aura_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class InsuranceComparisonScreen extends StatefulWidget {
  final InsuranceProfile profile;

  /// Years of income support from the completed assessment (if known), used so
  /// the backend can produce a personalized comparison.
  final int? yearsOfSupport;

  const InsuranceComparisonScreen({
    super.key,
    required this.profile,
    this.yearsOfSupport,
  });

  @override
  State<InsuranceComparisonScreen> createState() =>
      _InsuranceComparisonScreenState();
}

class _InsuranceComparisonScreenState
    extends State<InsuranceComparisonScreen> {
  final AuraApi _api = AuraApi();

  AuraTradeoff? _tradeoff;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = widget.profile;
    final auraProfile = AuraProfile(
      dependentsCount: p.dependents,
      yearsOfSupport: widget.yearsOfSupport,
      annualIncome: p.annualIncome,
      totalDebts: p.debts,
      futureGoals: p.futureNeeds,
      existingCoverage: p.existingCoverage,
    );
    try {
      final result = await _api.tradeoffs(auraProfile);
      if (!mounted) return;
      setState(() {
        _tradeoff = result; // null => incomplete profile, show static copy
        _loading = false;
      });
    } on AuraApiException {
      if (!mounted) return;
      setState(() => _loading = false); // network issue => static copy
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = AppColors.primaryText;
    final secondaryText = AppColors.secondaryText;
    final t = _tradeoff;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryText,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Compare',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Term vs.\nPermanent',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 36,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Lincoln offers term and permanent coverage (Indexed '
                  'Universal Life and Variable Universal Life). They are '
                  'designed for different needs.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                _PolicyCard(
                  title: 'Term Life',
                  badge: 'Simple protection',
                  icon: Icons.schedule_rounded,
                  accent: AppColors.amber,
                  description:
                      'Coverage lasts for a defined period, such as 10, '
                      '20 or 30 years. Term has no cash value.',
                  points: const [
                    'Designed for a specific period',
                    'Generally lower cost for the same amount',
                    'Useful during high-responsibility years',
                    'Can protect income, debt and family needs',
                  ],
                ),

                const SizedBox(height: 14),

                _PolicyCard(
                  title: 'Permanent (IUL / VUL)',
                  badge: 'Longer-term coverage',
                  icon: Icons.all_inclusive_rounded,
                  accent: AppColors.auroraViolet,
                  description:
                      'Lincoln\'s permanent options can last up to a '
                      'lifetime and may build cash value. (Lincoln does '
                      'not offer whole life.)',
                  points: const [
                    'Indexed Universal Life: growth tied to an index, with '
                        'some protection from market loss',
                    'Variable Universal Life: growth follows chosen '
                        'investments and can go up or down',
                    'Can build cash value accessible during life',
                    'Generally higher cost and more complexity than term',
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'For your situation',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(
                      alpha: AppColors.isDay ? 0.14 : 0.09,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.amberShadow,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _loading
                            ? Text(
                                'Asking Aura to tailor this to your '
                                'numbers...',
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 12.5,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Text(
                                t?.tradeoffAnalysis ?? _staticInsight(),
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 12.5,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                if (t != null) ...[
                  const SizedBox(height: 14),
                  _FitRow(label: 'Where term fits', text: t.termFit),
                  const SizedBox(height: 10),
                  _FitRow(
                    label: 'Where permanent (IUL/VUL) fits',
                    text: t.permanentFit,
                  ),
                ],

                const SizedBox(height: 28),

                Text(
                  'At a glance',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                _CompareRow(
                  label: 'Coverage length',
                  term: 'Set period',
                  permanent: 'Up to lifetime',
                ),
                _CompareRow(
                  label: 'Cost',
                  term: 'Generally lower',
                  permanent: 'Generally higher',
                ),
                _CompareRow(
                  label: 'Cash value',
                  term: 'None',
                  permanent: 'Can build',
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Text(
                    t?.disclaimer ??
                        'Educational comparison only. Policy costs, features '
                            'and suitability vary. A licensed Lincoln Financial '
                            'professional can provide quotes.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _staticInsight() {
    final p = widget.profile;
    if (p.dependents > 0 && p.debts > 0) {
      return 'Because you have ${p.dependents} '
          '${p.dependents == 1 ? 'dependent' : 'dependents'} and '
          'outstanding debt, much of your need is tied to a period — the '
          'situation term is often used for. Lincoln\'s permanent options '
          '(IUL/VUL) may be worth comparing for longer-term goals.';
    }
    if (p.dependents > 0) {
      return 'Because other people rely on your income, coverage during your '
          'major earning and family-support years may be particularly '
          'important. Term is often used for time-bound needs.';
    }
    if (p.debts > 0) {
      return 'Your outstanding debt is an important consideration. Term '
          'coverage may help protect those obligations during a defined '
          'period.';
    }
    return 'The better fit depends on how long you need protection, your '
        'financial responsibilities, and whether you want longer-term '
        'coverage with cash value (Lincoln\'s IUL/VUL).';
  }
}

class _FitRow extends StatelessWidget {
  final String label;
  final String text;

  const _FitRow({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.amberShadow,
              fontSize: 9.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final Color accent;
  final List<String> points;

  const _PolicyCard({
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    required this.accent,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.13),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String term;
  final String permanent;

  const _CompareRow({
    required this.label,
    required this.term,
    required this.permanent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _CompareValue(
                  title: 'TERM',
                  value: term,
                  color: AppColors.amberShadow,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _CompareValue(
                  title: 'PERMANENT',
                  value: permanent,
                  color: AppColors.auroraViolet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompareValue extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _CompareValue({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
