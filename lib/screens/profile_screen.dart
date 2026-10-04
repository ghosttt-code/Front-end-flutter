import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class ProfileScreen extends StatelessWidget {
  final InsuranceProfile profile;
  final VoidCallback onRetakeAssessment;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onRetakeAssessment,
  });

  String _money(double value) {
    final text = value.round().toString();
    final result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final remaining = text.length - i;

      result.write(text[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        result.write(',');
      }
    }

    return '\$${result.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = AppColors.primaryText;
    final secondaryText = AppColors.secondaryText;

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            125,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 22),

              _Card(
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'LincolnLife profile',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Assessment details',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              _Card(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileRow(
                      label: 'Dependents',
                      value: '${profile.dependents}',
                    ),
                    const _Divider(),
                    _ProfileRow(
                      label: 'Annual income',
                      value: _money(profile.annualIncome),
                    ),
                    const _Divider(),
                    _ProfileRow(
                      label: 'Outstanding debt',
                      value: _money(profile.debts),
                    ),
                    const _Divider(),
                    _ProfileRow(
                      label: 'Future needs',
                      value: _money(profile.futureNeeds),
                    ),
                    const _Divider(),
                    _ProfileRow(
                      label: 'Existing coverage',
                      value: _money(profile.existingCoverage),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Security & privacy',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              _Card(
                child: Column(
                  children: [
                    _SecurityRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Managed authentication',
                      text:
                          'LincolnLife is designed to use a managed '
                          'identity provider rather than storing or '
                          'implementing passwords directly in the app.',
                    ),

                    const SizedBox(height: 18),

                    _SecurityRow(
                      icon: Icons.key_off_outlined,
                      title: 'No API keys in Flutter',
                      text:
                          'Private API keys and backend credentials '
                          'should remain on the server, not in the '
                          'mobile application source code.',
                    ),

                    const SizedBox(height: 18),

                    _SecurityRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Minimal assessment data',
                      text:
                          'The prototype only uses information needed '
                          'to calculate and explain the coverage estimate.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onRetakeAssessment,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.amber,
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Update My Assessment',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline,
        ),
      ),
      child: child,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.outline,
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _SecurityRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.amber,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}