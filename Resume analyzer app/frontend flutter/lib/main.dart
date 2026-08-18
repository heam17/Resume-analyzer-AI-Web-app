import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const AIResumeAnalyzerApp());
}

class AIResumeAnalyzerApp extends StatelessWidget {
  const AIResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surfaceDim,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const HomePage(),
    );
  }
}

/// -----------------------------------------------------------------------
/// Design System — "Lumina Resume" color palette (matches uploaded design)
/// -----------------------------------------------------------------------
class AppColors {
  AppColors._();

  static const Color surfaceDim = Color(0xFF121414);
  static const Color surface = Color(0xFF121414);
  static const Color background = Color(0xFF121414);
  static const Color surfaceBright = Color(0xFF37393A);
  static const Color surfaceContainerLowest = Color(0xFF0C0F0F);
  static const Color surfaceContainerLow = Color(0xFF1A1C1C);
  static const Color surfaceContainer = Color(0xFF1E2020);
  static const Color surfaceContainerHigh = Color(0xFF282A2B);
  static const Color surfaceContainerHighest = Color(0xFF333535);
  static const Color surfaceVariant = Color(0xFF333535);

  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onBackground = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFC0C6D6);
  static const Color outline = Color(0xFF8B91A0);
  static const Color outlineVariant = Color(0xFF414754);

  static const Color primary = Color(0xFFAAC7FF);
  static const Color onPrimary = Color(0xFF003064);
  static const Color primaryContainer = Color(0xFF3E90FF);
  static const Color onPrimaryContainer = Color(0xFF002957);

  static const Color secondary = Color(0xFFC2C1FF);
  static const Color onSecondary = Color(0xFF1800A7);
  static const Color secondaryContainer = Color(0xFF3630BF);
  static const Color onSecondaryContainer = Color(0xFFB1B1FF);

  static const Color tertiary = Color(0xFF42E355);
  static const Color onTertiary = Color(0xFF00390A);
  static const Color tertiaryContainer = Color(0xFF00A82F);
  static const Color onTertiaryContainer = Color(0xFF003208);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
}

/// -----------------------------------------------------------------------
/// Atmospheric floating background — mirrors the `.floating-bg` blobs from
/// the HTML reference design. Shared across all screens for visual
/// continuity.
/// -----------------------------------------------------------------------
class FloatingBackground extends StatefulWidget {
  const FloatingBackground({super.key});

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final shift = 24 * _controller.value;
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Stack(
                children: [
                  Positioned(
                    top: -size.height * 0.12 - shift,
                    left: -size.width * 0.28,
                    child: _blob(size.width * 0.85, AppColors.primary.withOpacity(0.22)),
                  ),
                  Positioned(
                    top: size.height * 0.32 + shift,
                    right: -size.width * 0.3,
                    child: _blob(size.width * 0.95, AppColors.secondaryContainer.withOpacity(0.2)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _blob(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
