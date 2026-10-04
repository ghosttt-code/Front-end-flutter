import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuraButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const AuraButton({
    super.key,
    required this.onTap,
    this.size = 64,
  });

  @override
  State<AuraButton> createState() => _AuraButtonState();
}

class _AuraButtonState extends State<AuraButton>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _tapController;

  late final Animation<double> _hoverAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _tapScaleAnimation;

  bool _isOpening = false;

  @override
  void initState() {
    super.initState();

    // Gentle floating / glowing animation.
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );

    // Quick bounce when tapped.
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _tapScaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 0.82,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.82,
            end: 1.15,
          ).chain(
            CurveTween(
              curve: Curves.easeOutBack,
            ),
          ),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.15,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 35,
        ),
      ],
    ).animate(_tapController);
  }

  Future<void> _handleTap() async {
    if (_isOpening) {
      return;
    }

    _isOpening = true;

    await _tapController.forward(from: 0);

    if (!mounted) {
      return;
    }

    widget.onTap();

    _isOpening = false;
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [
          _idleController,
          _tapController,
        ],
      ),
      builder: (context, child) {
        final glow = _glowAnimation.value;

        return Transform.translate(
          offset: Offset(
            0,
            _hoverAnimation.value,
          ),
          child: Transform.scale(
            scale: _tapController.isAnimating
                ? _tapScaleAnimation.value
                : 1.0,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.amberHighlight,
                      AppColors.amber,
                      AppColors.amberShadow,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(
                        alpha: 0.26 + (0.18 * glow),
                      ),
                      blurRadius: 20 + (18 * glow),
                      spreadRadius: 2 + (3 * glow),
                    ),
                    BoxShadow(
                      color: AppColors.auroraViolet.withValues(
                        alpha: 0.08 + (0.09 * glow),
                      ),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.amber,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}