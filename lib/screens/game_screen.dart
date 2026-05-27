import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/game_store.dart';
import '../state/game_state.dart';
import '../widgets/confetti_overlay.dart';

class GameScreen extends StatefulWidget {
  final GameStore store;
  final GameState gameState;
  final VoidCallback onToggleTheme;

  const GameScreen({super.key, required this.store, required this.gameState, required this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Timer? _timer;
  bool _showConfetti = false;
  final FocusNode _focusNode = FocusNode();

  // Animation for selected cell
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  GameState get game => widget.gameState;
  GameStore get store => widget.store;
  AppColorScheme get colors => store.isDark ? AppColors.dark : AppColors.light;

  // Calculate progress percentage
  int get _filledCells {
    if (game.board.isEmpty) return 0;
    int count = 0;
    for (var row in game.board) {
      for (var cell in row) {
        if (cell != 0) count++;
      }
    }
    return count;
  }

  double get _progress => _filledCells / 81;

  @override
  void initState() {
    super.initState();
    _startTimer();
    game.addListener(_onGameChange);
    _focusNode.requestFocus();

    // Setup selection animation
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _selectionAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeOut),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        game.tick();
      }
    });
  }

  void _onGameChange() {
    if (!mounted) return;
    if (game.isGenerating) {
      setState(() {});
      return;
    }
    if (game.status == GameStatus.won) {
      _timer?.cancel();
      store.recordWin(game.difficulty, game.seconds, game.mistakes);
      HapticFeedback.heavyImpact();
      setState(() => _showConfetti = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showWinDialog();
      });
    } else if (game.status == GameStatus.lost) {
      _timer?.cancel();
      store.recordLoss(game.difficulty, game.seconds, game.mistakes);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showLoseDialog();
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _selectionController.dispose();
    game.removeListener(_onGameChange);
    if (!game.gameOver && game.puzzle.isNotEmpty && !game.isGenerating) {
      store.saveGame(game.toSavedGame());
    }
    super.dispose();
  }

  void _newGame() async {
    final seed = game.challengeMode ? game.challengeSeed : null;
    final pin = game.challengeMode ? game.challengePin : null;
    setState(() => _showConfetti = false);
    _timer?.cancel();
    await game.newGame(game.difficulty, seed: seed, pin: pin);
    if (mounted) _startTimer();
  }

  // Handle keyboard input
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (game.paused || game.gameOver || game.isGenerating) return;

    final key = event.logicalKey;

    // Number keys 1-9
    if (key.keyId >= LogicalKeyboardKey.digit1.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final num = key.keyId - LogicalKeyboardKey.digit0.keyId;
      if (game.countForNumber(num) < 9) {
        HapticFeedback.lightImpact();
        game.inputNumber(num);
      }
      return;
    }

    // Numpad 1-9
    if (key.keyId >= LogicalKeyboardKey.numpad1.keyId &&
        key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      final num = key.keyId - LogicalKeyboardKey.numpad0.keyId;
      if (game.countForNumber(num) < 9) {
        HapticFeedback.lightImpact();
        game.inputNumber(num);
      }
      return;
    }

    // Arrow keys for navigation
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1, 0);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1, 0);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _moveSelection(0, -1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveSelection(0, 1);
    }

    // Backspace/Delete to erase
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      HapticFeedback.lightImpact();
      game.eraseCell();
    }

    // N for notes toggle
    if (key == LogicalKeyboardKey.keyN) {
      HapticFeedback.selectionClick();
      game.toggleNotes();
    }

    // Z for undo
    if (key == LogicalKeyboardKey.keyZ) {
      HapticFeedback.lightImpact();
      game.undo();
    }

    // H for hint
    if (key == LogicalKeyboardKey.keyH) {
      HapticFeedback.mediumImpact();
      game.giveHint();
    }

    // Space to pause
    if (key == LogicalKeyboardKey.space) {
      game.togglePause();
    }
  }

  void _moveSelection(int dr, int dc) {
    int r = game.selectedRow ?? 4;
    int c = game.selectedCol ?? 4;
    r = (r + dr).clamp(0, 8);
    c = (c + dc).clamp(0, 8);
    HapticFeedback.selectionClick();
    game.selectCell(r, c);
    _selectionController.forward(from: 0);
  }

  void _onCellTap(int r, int c) {
    HapticFeedback.selectionClick();
    game.selectCell(r, c);
    _selectionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        _buildHeader(c),
                        const SizedBox(height: 16),
                        _buildStatsBar(c),
                        const SizedBox(height: 8),
                        _buildProgressBar(c),
                        const SizedBox(height: 14),
                        _buildBoard(c),
                        const SizedBox(height: 14),
                        _buildNumpad(c),
                        const SizedBox(height: 10),
                        _buildActionBar(c),
                        const SizedBox(height: 12),
                        _buildNewGameButton(),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showConfetti) const ConfettiOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: c.textMuted),
                // const SizedBox(width: 4),
                // Text('Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.textMuted)),
              ],
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]).createShader(bounds),
          child: const Text('Sudoku', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1, color: Colors.white)),
        ),
        Row(
          children: [
            if (game.challengeMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF72585), Color(0xFF7209B7)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Challenge', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onToggleTheme();
              },
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface, border: Border.all(color: c.border)),
                alignment: Alignment.center,
                child: Text(store.isDark ? '☀️' : '🌙', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsBar(AppColorScheme c) {
    final diffColors = _getDifficultyColors(game.difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: diffColors.$1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              game.difficulty[0].toUpperCase() + game.difficulty.substring(1),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: diffColors.$2),
            ),
          ),
          // Mistakes
          Row(
            children: [
              ...List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < game.mistakes ? c.errColor : c.border,
                    boxShadow: i < game.mistakes ? [
                      BoxShadow(color: c.errColor.withValues(alpha: 0.5), blurRadius: 4),
                    ] : null,
                  ),
                ),
              )),
            ],
          ),
          // Timer
          Row(
            children: [
              Text(_fmtTime(game.seconds), style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: c.text, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  game.togglePause();
                },
                child: Text(game.paused ? '▶' : '⏸', style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColorScheme c) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.textMuted)),
            Text('${(_progress * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.primary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: c.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(c.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(AppColorScheme c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: (game.puzzle.isEmpty || game.isGenerating)
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    itemCount: 81,
                    itemBuilder: (ctx, idx) {
                      final r = idx ~/ 9, col = idx % 9;
                      return _buildCell(r, col, c);
                    },
                  ),
          ),
          // Pause overlay
          if (game.paused)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  game.togglePause();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⏸', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text('Tap to resume', style: TextStyle(fontSize: 13, color: c.textMuted)),
                      const SizedBox(height: 4),
                      Text('or press Space', style: TextStyle(fontSize: 11, color: c.textMuted.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c, AppColorScheme col) {
    final val = game.board[r][c];
    final given = game.isGiven[r][c];
    final isSel = r == game.selectedRow && c == game.selectedCol;
    final inGroup = !isSel && game.hasSelection &&
        (r == game.selectedRow || c == game.selectedCol ||
            (r ~/ 3 == game.selectedRow! ~/ 3 && c ~/ 3 == game.selectedCol! ~/ 3));
    final sameNum = !isSel && game.selectedValue > 0 && val == game.selectedValue;
    final isErr = !given && val != 0 && val != game.solution[r][c];
    final isHint = game.hintCells.contains('$r,$c');

    Color bgColor = Colors.transparent;
    if (isSel) {
      bgColor = col.selBg;
    } else if (sameNum) {
      bgColor = col.sameBg;
    } else if (inGroup) {
      bgColor = col.hlBg;
    }
    if (isErr) bgColor = col.errBg;

    Color textColor = col.text;
    if (isErr) {
      textColor = col.errColor;
    } else if (given) {
      textColor = col.givenColor;
    } else if (isHint) {
      textColor = col.hintColor;
    } else if (val != 0) {
      textColor = col.userColor;
    }

    // Borders
    final rightBorder = (c == 2 || c == 5 || c == 8) ? BorderSide(color: col.borderBox, width: 2.5) : BorderSide(color: col.border, width: 0.5);
    final bottomBorder = (r == 2 || r == 5 || r == 8) ? BorderSide(color: col.borderBox, width: 2.5) : BorderSide(color: col.border, width: 0.5);
    final leftBorder = c == 0 ? BorderSide(color: col.borderBox, width: 2.5) : BorderSide.none;
    final topBorder = r == 0 ? BorderSide(color: col.borderBox, width: 2.5) : BorderSide.none;

    Widget cellContent = Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: rightBorder, bottom: bottomBorder, left: leftBorder, top: topBorder),
      ),
      alignment: Alignment.center,
      child: val != 0
          ? Text('$val', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor))
          : game.notes[r][c].isNotEmpty
              ? _buildNotes(r, c, col)
              : null,
    );

    // Add scale animation for selected cell
    if (isSel) {
      cellContent = AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) => Transform.scale(
          scale: _selectionAnimation.value,
          child: child,
        ),
        child: cellContent,
      );
    }

    return GestureDetector(
      onTap: () => _onCellTap(r, c),
      child: cellContent,
    );
  }

  Widget _buildNotes(int r, int c, AppColorScheme col) {
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      children: List.generate(9, (i) {
        final n = i + 1;
        return Center(
          child: Text(
            game.notes[r][c].contains(n) ? '$n' : '',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: col.noteColor),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad(AppColorScheme c) {
    return Row(
      children: List.generate(9, (i) {
        final n = i + 1;
        final count = game.countForNumber(n);
        final depleted = count >= 9;
        final isComplete = depleted;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: GestureDetector(
              onTap: depleted ? null : () {
                HapticFeedback.lightImpact();
                game.inputNumber(n);
              },
              child: AspectRatio(
                aspectRatio: 0.9,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(
                      color: isComplete ? c.hintColor.withValues(alpha: 0.5) : c.border,
                      width: isComplete ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isComplete ? [
                      BoxShadow(color: c.hintColor.withValues(alpha: 0.3), blurRadius: 8),
                    ] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: depleted ? 0.25 : 1,
                        child: Text('$n', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isComplete ? c.hintColor : c.text,
                        )),
                      ),
                      if (!depleted)
                        Positioned(
                          top: 2,
                          right: 3,
                          child: Text('${9 - count}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: c.textMuted)),
                        ),
                      if (isComplete)
                        Positioned(
                          top: 2,
                          right: 3,
                          child: Icon(Icons.check, size: 10, color: c.hintColor),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionBar(AppColorScheme c) {
    return Row(
      children: [
        _actionBtn('↩', 'Undo', 'Z', false, () {
          HapticFeedback.lightImpact();
          game.undo();
        }, c),
        const SizedBox(width: 8),
        _actionBtn('⌫', 'Erase', '⌫', false, () {
          HapticFeedback.lightImpact();
          game.eraseCell();
        }, c),
        const SizedBox(width: 8),
        _actionBtn('✏️', 'Notes', 'N', game.notesMode, () {
          HapticFeedback.selectionClick();
          game.toggleNotes();
        }, c),
        const SizedBox(width: 8),
        _actionBtn('💡', 'Hint', 'H', false, () {
          HapticFeedback.mediumImpact();
          game.giveHint();
        }, c),
      ],
    );
  }

  Widget _actionBtn(String icon, String label, String shortcut, bool active, VoidCallback onTap, AppColorScheme c) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? c.primary : c.surface,
            border: Border.all(color: active ? c.primary : c.border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: TextStyle(fontSize: 17, color: active ? Colors.white : c.textMuted)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : c.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewGameButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _newGame();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFF4F6EF7).withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: const Text('New Game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  (Color, Color) _getDifficultyColors(String diff) {
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
        return (colors.surface2, colors.textMuted);
    }
  }

  void _showWinDialog() {
    final c = colors;
    if (game.challengeMode) {
      _showChallengeWinDialog(c);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(
        colors: c,
        time: _fmtTime(game.seconds),
        mistakes: '${game.mistakes}',
        difficulty: game.difficulty[0].toUpperCase() + game.difficulty.substring(1),
        onPlayAgain: () { Navigator.pop(context); _newGame(); },
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  void _showLoseDialog() {
    final c = colors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoseDialog(
        colors: c,
        onTryAgain: () { Navigator.pop(context); _newGame(); },
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  void _showChallengeWinDialog(AppColorScheme c) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChallengeWinDialog(
        colors: c,
        time: _fmtTime(game.seconds),
        mistakes: '${game.mistakes}',
        difficulty: game.difficulty[0].toUpperCase() + game.difficulty.substring(1),
        pin: game.challengePin ?? '',
        onReplay: () {
          Navigator.pop(context);
          final s = game.challengeSeed;
          final p = game.challengePin;
          final d = game.difficulty;
          game.newGame(d, seed: s, pin: p);
          _startTimer();
          setState(() => _showConfetti = false);
        },
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  String _fmtTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

// ── Win Dialog ──
class _WinDialog extends StatelessWidget {
  final AppColorScheme colors;
  final String time, mistakes, difficulty;
  final VoidCallback onPlayAgain, onHome;

  const _WinDialog({required this.colors, required this.time, required this.mistakes, required this.difficulty, required this.onPlayAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text('Puzzle Solved!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: colors.text)),
            const SizedBox(height: 6),
            Text('Excellent work!', style: TextStyle(fontSize: 14, color: colors.textMuted)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(time, 'Time'),
                  _stat(mistakes, 'Mistakes'),
                  _stat(difficulty, 'Difficulty'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _gradientBtn('Play Again', onPlayAgain),
            const SizedBox(height: 8),
            _outlineBtn('Home', onHome, colors),
          ],
        ),
      ),
    );
  }

  Widget _stat(String val, String lbl) => Column(
    children: [
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colors.primary)),
      const SizedBox(height: 2),
      Text(lbl, style: TextStyle(fontSize: 10, color: colors.textMuted)),
    ],
  );
}

// ── Lose Dialog ──
class _LoseDialog extends StatelessWidget {
  final AppColorScheme colors;
  final VoidCallback onTryAgain, onHome;

  const _LoseDialog({required this.colors, required this.onTryAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💀', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text('Game Over', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: colors.text)),
            const SizedBox(height: 6),
            Text('Too many mistakes — solution revealed.', style: TextStyle(fontSize: 14, color: colors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            _gradientBtn('Try Again', onTryAgain),
            const SizedBox(height: 8),
            _outlineBtn('Home', onHome, colors),
          ],
        ),
      ),
    );
  }
}

// ── Challenge Win Dialog ──
class _ChallengeWinDialog extends StatelessWidget {
  final AppColorScheme colors;
  final String time, mistakes, difficulty, pin;
  final VoidCallback onReplay, onHome;

  const _ChallengeWinDialog({required this.colors, required this.time, required this.mistakes, required this.difficulty, required this.pin, required this.onReplay, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text('Challenge Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.text)),
            const SizedBox(height: 6),
            Text('Show your result to your friend!', style: TextStyle(fontSize: 13, color: colors.textMuted)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(time, 'Your Time'),
                  _stat(mistakes, 'Mistakes'),
                  _stat(difficulty, 'Difficulty'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('CHALLENGE PIN', style: TextStyle(fontSize: 10, color: colors.textMuted, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(pin, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colors.primary, letterSpacing: 5)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _gradientBtn('📋 Share Result', () {
              final txt = '🏆 I solved the Sudoku challenge!\nTime: $time, Mistakes: $mistakes\nChallenge PIN: $pin\nCan you beat me?';
              Clipboard.setData(ClipboardData(text: txt));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
            }),
            const SizedBox(height: 8),
            _outlineBtn('🔄 Replay Same Puzzle', onReplay, colors),
            const SizedBox(height: 8),
            _outlineBtn('Back to Home', onHome, colors),
          ],
        ),
      ),
    );
  }

  Widget _stat(String val, String lbl) => Column(
    children: [
      Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colors.primary)),
      const SizedBox(height: 2),
      Text(lbl, style: TextStyle(fontSize: 10, color: colors.textMuted)),
    ],
  );
}

// ── Shared Buttons ──
Widget _gradientBtn(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
    ),
  );
}

Widget _outlineBtn(String text, VoidCallback onTap, AppColorScheme c) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.text)),
    ),
  );
}
