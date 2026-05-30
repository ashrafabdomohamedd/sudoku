import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RateAppDialog extends StatelessWidget {
  final AppColorScheme colors;
  final VoidCallback onRate;
  final VoidCallback onLater;
  final VoidCallback onNever;

  const RateAppDialog({
    super.key,
    required this.colors,
    required this.onRate,
    required this.onLater,
    required this.onNever,
  });

  AppColorScheme get c => colors;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stars animation
              const Text(
                '⭐️⭐️⭐️⭐️⭐️',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Enjoying Sudoku?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: c.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'You\'re on a roll with ${3} perfect games!\nWould you mind rating us on the store?',
                style: TextStyle(
                  fontSize: 14,
                  color: c.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'It helps us a lot and keeps the game free!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Rate button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onRate();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F6EF7).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Rate Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Later button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onLater();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Never button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNever();
                },
                child: Text(
                  'Don\'t ask again',
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMuted,
                    decoration: TextDecoration.underline,
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
