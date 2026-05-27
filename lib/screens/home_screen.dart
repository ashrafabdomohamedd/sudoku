import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/game_store.dart';
import '../state/game_state.dart';
import '../screens/game_screen.dart';
import '../widgets/challenge_modal.dart';
import '../widgets/profile_edit_modal.dart';

class HomeScreen extends StatefulWidget {
  final GameStore store;
  final GameState gameState;
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.store, required this.gameState, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _difficulty = 'easy';

  GameStore get store => widget.store;
  AppColorScheme get colors => store.isDark ? AppColors.dark : AppColors.light;

  // Difficulty icons
  static const _diffIcons = {
    'easy': '🌱',
    'medium': '🔥',
    'hard': '💪',
    'expert': '🏆',
  };

  // Difficulty descriptions
  static const _diffDesc = {
    'easy': '38+ clues',
    'medium': '30-37 clues',
    'hard': '25-29 clues',
    'expert': '22-24 clues',
  };

  void _navigateToGame({int? seed, String? pin, String? diff}) {
    final d = diff ?? _difficulty;
    widget.gameState.newGame(d, seed: seed, pin: pin);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(store: store, gameState: widget.gameState, onToggleTheme: widget.onToggleTheme),
      ),
    ).then((_) => setState(() {}));
  }

  void _continueGame() {
    if (store.savedGame == null) return;
    widget.gameState.loadFromSaved(store.savedGame!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(store: store, gameState: widget.gameState, onToggleTheme: widget.onToggleTheme),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(c),
                  const SizedBox(height: 20),
                  _buildProfileCard(c),
                  const SizedBox(height: 16),
                  _buildStats(c),
                  const SizedBox(height: 20),
                  _sectionLabel('Select Difficulty', c),
                  const SizedBox(height: 12),
                  _buildDifficultyCards(c),
                  const SizedBox(height: 16),
                  _buildPlayButton(),
                  if (store.savedGame != null) ...[
                    const SizedBox(height: 10),
                    _buildContinueButton(c),
                  ],
                  const SizedBox(height: 10),
                  _buildChallengeButton(),
                  const SizedBox(height: 24),
                  _sectionLabel('Recent Scores', c),
                  const SizedBox(height: 9),
                  _buildScores(c),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
          ).createShader(bounds),
          child: const Text('Sudoku', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Colors.white)),
        ),
        Row(
          children: [
            _iconButton(store.isDark ? '☀️' : '🌙', widget.onToggleTheme, c),
            const SizedBox(width: 8),
            _iconButton('⚙️', () => _showProfileEdit(), c),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(String icon, VoidCallback onTap, AppColorScheme c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.surface,
          border: Border.all(color: c.border),
        ),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildProfileCard(AppColorScheme c) {
    final color = _parseColor(store.avatarColor);
    return GestureDetector(
      onTap: _showProfileEdit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF4F6EF7).withValues(alpha:0.38), blurRadius: 32, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white.withValues(alpha:0.3), width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                store.name.isNotEmpty ? store.name[0].toUpperCase() : 'P',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text('${store.rankIcon} ${store.rankName}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha:0.65))),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${store.won} win${store.won != 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha:0.9))),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.18),
                border: Border.all(color: Colors.white.withValues(alpha:0.28)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(AppColorScheme c) {
    return Row(
      children: [
        _statCard('${store.played}', 'Played', c),
        const SizedBox(width: 10),
        _statCard('${store.won}', 'Won', c),
        const SizedBox(width: 10),
        _statCard(store.winRate, 'Win Rate', c),
      ],
    );
  }

  Widget _statCard(String value, String label, AppColorScheme c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: c.primary.withValues(alpha:0.1), blurRadius: 24, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.primary)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, AppColorScheme c) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c.textMuted, letterSpacing: 1));
  }

  Widget _buildDifficultyCards(AppColorScheme c) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDifficultyCard('easy', c)),
            const SizedBox(width: 10),
            Expanded(child: _buildDifficultyCard('medium', c)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDifficultyCard('hard', c)),
            const SizedBox(width: 10),
            Expanded(child: _buildDifficultyCard('expert', c)),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(String diff, AppColorScheme c) {
    final isSelected = diff == _difficulty;
    final bestTime = store.bestTimes[diff];
    final badge = _diffBadge(diff, c);
    final icon = _diffIcons[diff] ?? '🎮';
    final desc = _diffDesc[diff] ?? '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _difficulty = diff);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? badge.$2 : c.border,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: badge.$2.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      diff[0].toUpperCase() + diff.substring(1),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? badge.$2 : c.text,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badge.$2,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: c.textMuted),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badge.$1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: bestTime != null ? badge.$2 : c.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bestTime != null ? _fmtTime(bestTime) : 'No record',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: bestTime != null ? badge.$2 : c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        store.clearSavedGame();
        _navigateToGame();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF4F6EF7).withValues(alpha:0.4), blurRadius: 22, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: const Text('▶  New Game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildContinueButton(AppColorScheme c) {
    return GestureDetector(
      onTap: _continueGame,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.primary, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text('↩  Continue Game', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.primary)),
      ),
    );
  }

  Widget _buildChallengeButton() {
    return GestureDetector(
      onTap: () => _showChallengeModal(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF72585), Color(0xFF7209B7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFF72585).withValues(alpha:0.35), blurRadius: 22, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: const Text('⚔️  Challenge a Friend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildScores(AppColorScheme c) {
    if (store.scores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text('No games played yet.\nStart your first puzzle!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.textMuted)),
      );
    }
    return Column(
      children: store.scores.take(10).map((s) {
        final badge = _diffBadge(s.diff, c);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: c.primary.withValues(alpha:0.1), blurRadius: 24, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badge.$1, borderRadius: BorderRadius.circular(6)),
                child: Text(s.diff.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badge.$2, letterSpacing: 0.4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fmtTime(s.time), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.text)),
                    Text('${s.mistakes} mistake${s.mistakes != 1 ? 's' : ''}', style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ],
                ),
              ),
              Text(s.date, style: TextStyle(fontSize: 11, color: c.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  (Color, Color) _diffBadge(String diff, AppColorScheme c) {
    final isDark = store.isDark;
    switch (diff) {
      case 'easy':
        return isDark ? (DiffBadgeColors.easyDark.bg, DiffBadgeColors.easyDark.text) : (DiffBadgeColors.easy.bg, DiffBadgeColors.easy.text);
      case 'medium':
        return isDark ? (DiffBadgeColors.mediumDark.bg, DiffBadgeColors.mediumDark.text) : (DiffBadgeColors.medium.bg, DiffBadgeColors.medium.text);
      case 'hard':
        return isDark ? (DiffBadgeColors.hardDark.bg, DiffBadgeColors.hardDark.text) : (DiffBadgeColors.hard.bg, DiffBadgeColors.hard.text);
      case 'expert':
        return isDark ? (DiffBadgeColors.expertDark.bg, DiffBadgeColors.expertDark.text) : (DiffBadgeColors.expert.bg, DiffBadgeColors.expert.text);
      default:
        return (c.surface2, c.textMuted);
    }
  }

  void _showProfileEdit() {
    showDialog(
      context: context,
      builder: (_) => ProfileEditModal(
        store: store,
        colors: colors,
        onSave: () => setState(() {}),
      ),
    );
  }

  void _showChallengeModal() {
    showDialog(
      context: context,
      builder: (_) => ChallengeModal(
        colors: colors,
        isDark: store.isDark,
        onStartChallenge: (diff, seed, pin) {
          Navigator.of(context).pop();
          _navigateToGame(diff: diff, seed: seed, pin: pin);
        },
      ),
    );
  }

  String _fmtTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

