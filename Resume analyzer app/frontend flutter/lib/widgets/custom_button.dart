import 'package:flutter/material.dart';

import '../main.dart';

/// Primary call-to-action button used across the app. Mirrors the
/// `.system-button` gradient pill from the reference design and supports a
/// loading spinner + disabled state so it can be reused for the "Next" and
/// "Analyze Candidates" actions.
class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final double borderRadius;
  final List<Color>? gradientColors;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.width,
    this.borderRadius = 999,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, color: Colors.white, size: 16),
        ],
      ],
    );

    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedOpacity(
        opacity: (onPressed == null && !isLoading) ? 0.4 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: height,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors ?? [AppColors.primaryContainer, const Color(0xFF005DB8)],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: disabled
                ? const []
                : [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
