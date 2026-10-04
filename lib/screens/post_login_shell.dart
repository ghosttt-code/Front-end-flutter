import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_button.dart';

import 'ai_assistant_screen.dart';
import 'dashboard_screen.dart';
import 'insurance_comparison_screen.dart';
import 'profile_screen.dart';
import 'results_screen.dart';
import 'services_screen.dart';

class PostLoginShell extends StatefulWidget {
  const PostLoginShell({
    super.key,
  });

  @override
  State<PostLoginShell> createState() =>
      _PostLoginShellState();
}

class _PostLoginShellState extends State<PostLoginShell> {
  int _selectedIndex = 0;

  InsuranceProfile _profile =
      InsuranceProfile.demo();

  Future<void> _openAura() async {
    final updated =
        await Navigator.push<InsuranceProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => AiAssistantScreen(
          initialProfile: _profile,
        ),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      _profile = updated;
    });

    final action =
        await Navigator.push<ResultsAction>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          profile: updated,
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == ResultsAction.dashboard) {
      setState(() {
        _selectedIndex = 1;
      });
    }

    if (action == ResultsAction.compare) {
      _openCompare();
    }
  }

  void _openCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InsuranceComparisonScreen(
          profile: _profile,
        ),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ServicesScreen(
        onStartAI: _openAura,
        onDashboard: () {
          _selectPage(1);
        },
        onCompare: _openCompare,
      ),

      DashboardScreen(
        profile: _profile,
        onAskAI: _openAura,
        onRecalculate: _openAura,
        onCompare: _openCompare,
      ),

      ProfileScreen(
        profile: _profile,
        onRetakeAssessment: _openAura,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,

      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          right: 4,
          bottom: 10,
        ),
        child: AuraButton(
          size: 64,
          onTap: _openAura,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Container(
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.navBar,
          border: Border(
            top: BorderSide(
              color: AppColors.outline,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: _NavButton(
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore_rounded,
                  label: 'Explore',
                  selected: _selectedIndex == 0,
                  onTap: () {
                    _selectPage(0);
                  },
                ),
              ),

              Expanded(
                child: _NavButton(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  selected: _selectedIndex == 1,
                  onTap: () {
                    _selectPage(1);
                  },
                ),
              ),

              Expanded(
                child: _NavButton(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _selectedIndex == 2,
                  onTap: () {
                    _selectPage(2);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.amberShadow
        : AppColors.navUnselected;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? selectedIcon
                    : icon,
                color: color,
                size: 22,
              ),

              const SizedBox(height: 5),

              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}