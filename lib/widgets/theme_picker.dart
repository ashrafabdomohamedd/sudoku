import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/board_themes.dart';
import '../state/game_store.dart';

/// Full theme picker modal for Settings
class ThemePickerModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const ThemePickerModal({
    super.key,
    required this.store,
    required this.colors,
  });

  @override
  State<ThemePickerModal> createState() => _ThemePickerModalState();
}

class _ThemePickerModalState extends State<ThemePickerModal> {
  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🎨', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Text(
                        'Themes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: c.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color Themes Section
                    _sectionTitle('COLOR THEME'),
                    const SizedBox(height: 12),
                    _buildColorThemeGrid(),
                    const SizedBox(height: 24),

                    // Board Styles Section
                    _sectionTitle('BOARD STYLE'),
                    const SizedBox(height: 12),
                    _buildBoardStyleGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: c.textMuted,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildColorThemeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ColorThemes.all.map((theme) {
        final isSelected = store.colorThemeId == theme.id;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            store.setColorTheme(theme.id);
            setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? c.primary.withValues(alpha: 0.1) : c.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? c.primary : c.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // Color preview circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border, width: 1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border, width: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  theme.icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  theme.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? c.primary : c.text,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoardStyleGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: BoardStyles.all.map((style) {
        final isSelected = store.boardStyleId == style.id;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            store.setBoardStyle(style.id);
            setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? c.primary.withValues(alpha: 0.1) : c.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? c.primary : c.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // Mini board preview
                _buildMiniBoard(style),
                const SizedBox(height: 8),
                Text(
                  style.icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  style.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? c.primary : c.text,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniBoard(BoardStyle style) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(style.cellBorderRadius / 2),
        border: Border.all(color: c.borderBox, width: style.boxBorderWidth / 2),
        boxShadow: style.hasOuterGlow
            ? [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 4)]
            : null,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: c.border,
                width: style.cellBorderWidth / 2,
              ),
              borderRadius: BorderRadius.circular(style.cellBorderRadius / 3),
            ),
            margin: EdgeInsets.all(style.cellSpacing / 2),
          );
        },
      ),
    );
  }
}

/// Quick theme toggle button for game screen
class QuickThemeButton extends StatelessWidget {
  final GameStore store;
  final AppColorScheme colors;
  final VoidCallback? onThemeChanged;

  const QuickThemeButton({
    super.key,
    required this.store,
    required this.colors,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _QuickThemeSheet(
            store: store,
            colors: colors,
            onChanged: onThemeChanged,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.palette_outlined, size: 20),
      ),
    );
  }
}

class _QuickThemeSheet extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;
  final VoidCallback? onChanged;

  const _QuickThemeSheet({
    required this.store,
    required this.colors,
    this.onChanged,
  });

  @override
  State<_QuickThemeSheet> createState() => _QuickThemeSheetState();
}

class _QuickThemeSheetState extends State<_QuickThemeSheet> {
  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color themes row
          Text(
            'COLOR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: c.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ColorThemes.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final theme = ColorThemes.all[i];
                final isSelected = store.colorThemeId == theme.id;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    store.setColorTheme(theme.id);
                    widget.onChanged?.call();
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? c.primary.withValues(alpha: 0.1) : c.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? c.primary : c.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? c.primary : c.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Board styles row
          Text(
            'BOARD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: c.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BoardStyles.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final style = BoardStyles.all[i];
                final isSelected = store.boardStyleId == style.id;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    store.setBoardStyle(style.id);
                    widget.onChanged?.call();
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? c.primary.withValues(alpha: 0.1) : c.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? c.primary : c.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(style.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          style.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? c.primary : c.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
