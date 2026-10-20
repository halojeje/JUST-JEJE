import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_themes.dart';
import '../theme/pattern_painters.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final ThemeItem theme;
  final ConfettiController? confettiController;

  const CustomScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    required this.theme,
    this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bg,
      body: Stack(
        children: [
          // Theme Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ThemePatternPainter(
                pattern: theme.pattern,
                patColor: theme.patColor,
                isDark: theme.isDark,
              ),
            ),
          ),

          // Main Responsive Content Canvas (Centered with Max Width 480px)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ?appBar,
                      Expanded(child: body),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti Celebratory Burst Overlay
          if (confettiController != null)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: theme.covers,
                numberOfParticles: 25,
                gravity: 0.3,
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatingActionButton,
    );
  }
}
