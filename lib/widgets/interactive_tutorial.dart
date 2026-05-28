import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Interactive tutorial where users practice basic Sudoku actions
class InteractiveTutorial extends StatefulWidget {
  final AppColorScheme colors;
  final VoidCallback onComplete;

  const InteractiveTutorial({
    super.key,
    required this.colors,
    required this.onComplete,
  });

  @override
  State<InteractiveTutorial> createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial>
    with TickerProviderStateMixin {
  AppColorScheme get c => widget.colors;

  int _currentStep = 0;
  bool _stepCompleted = false;

  // Mini 4x4 grid for tutorial (simpler than 9x9)
  final List<List<int>> _puzzle = [
    [1, 0, 3, 4],
    [0, 4, 0, 2],
    [4, 0, 2, 0],
    [2, 3, 0, 1],
  ];

  late List<List<int>> _board;
  late List<List<bool>> _isGiven;
  late List<List<Set<int>>> _notes;

  int? _selectedRow;
  int? _selectedCol;
  bool _notesMode = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _highlightController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _highlightAnimation;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Select a Cell',
      instruction: 'Tap the highlighted empty cell to select it',
      targetRow: 0,
      targetCol: 1,
      action: TutorialAction.selectCell,
    ),
    TutorialStep(
      title: 'Enter a Number',
      instruction: 'Now tap the number 2 below to fill the cell',
      targetNumber: 2,
      action: TutorialAction.inputNumber,
    ),
    TutorialStep(
      title: 'Great! Try Another',
      instruction: 'Select this empty cell',
      targetRow: 1,
      targetCol: 0,
      action: TutorialAction.selectCell,
    ),
    TutorialStep(
      title: 'Fill It In',
      instruction: 'Enter the number 3',
      targetNumber: 3,
      action: TutorialAction.inputNumber,
    ),
    TutorialStep(
      title: 'Notes Mode',
      instruction: 'Tap the Notes button to toggle notes mode',
      action: TutorialAction.toggleNotes,
    ),
    TutorialStep(
      title: 'Add a Note',
      instruction: 'Select this cell and add note 1',
      targetRow: 1,
      targetCol: 2,
      targetNumber: 1,
      action: TutorialAction.addNote,
    ),
    TutorialStep(
      title: 'Exit Notes Mode',
      instruction: 'Tap Notes again to exit notes mode',
      action: TutorialAction.toggleNotes,
    ),
    TutorialStep(
      title: 'You\'re Ready!',
      instruction: 'You\'ve learned the basics. Tap Continue to start playing!',
      action: TutorialAction.complete,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initBoard();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _highlightAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );
  }

  void _initBoard() {
    _board = List.generate(4, (r) => List.from(_puzzle[r]));
    _isGiven = List.generate(
        4, (r) => List.generate(4, (c) => _puzzle[r][c] != 0));
    _notes = List.generate(4, (r) => List.generate(4, (c) => <int>{}));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  TutorialStep get _step => _steps[_currentStep];

  void _onCellTap(int r, int c) {
    if (_isGiven[r][c]) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });

    // Check if this completes the step
    if (_step.action == TutorialAction.selectCell &&
        _step.targetRow == r &&
        _step.targetCol == c) {
      _completeStep();
    } else if (_step.action == TutorialAction.addNote &&
        _step.targetRow == r &&
        _step.targetCol == c &&
        !_stepCompleted) {
      // Cell selected for note, now waiting for number
    }
  }

  void _onNumberTap(int n) {
    if (_selectedRow == null || _selectedCol == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      if (_notesMode) {
        if (_notes[_selectedRow!][_selectedCol!].contains(n)) {
          _notes[_selectedRow!][_selectedCol!].remove(n);
        } else {
          _notes[_selectedRow!][_selectedCol!].add(n);
        }
      } else {
        _board[_selectedRow!][_selectedCol!] = n;
        _notes[_selectedRow!][_selectedCol!].clear();
      }
    });

    // Check if this completes the step
    if (_step.action == TutorialAction.inputNumber &&
        _step.targetNumber == n &&
        !_notesMode) {
      _completeStep();
    } else if (_step.action == TutorialAction.addNote &&
        _step.targetNumber == n &&
        _notesMode) {
      _completeStep();
    }
  }

  void _onNotesToggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _notesMode = !_notesMode;
    });

    if (_step.action == TutorialAction.toggleNotes) {
      _completeStep();
    }
  }

  void _completeStep() {
    setState(() => _stepCompleted = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
          _stepCompleted = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildProgressIndicator(),
                const SizedBox(height: 20),
                _buildInstructions(),
                const SizedBox(height: 20),
                _buildMiniBoard(),
                const SizedBox(height: 16),
                _buildNumpad(),
                const SizedBox(height: 12),
                _buildActions(),
                const SizedBox(height: 16),
                if (_step.action == TutorialAction.complete)
                  _buildCompleteButton()
                else
                  _buildSkipButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interactive Tutorial',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: c.text,
                ),
              ),
              Text(
                'Learn by doing',
                style: TextStyle(
                  fontSize: 12,
                  color: c.textMuted,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_steps.length, (i) {
        final isComplete = i < _currentStep;
        final isCurrent = i == _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < _steps.length - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isComplete
                  ? c.primary
                  : isCurrent
                      ? c.primary.withValues(alpha: 0.5)
                      : c.surface2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInstructions() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              c.primary.withValues(alpha: 0.1),
              c.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              _step.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _step.instruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: c.text,
              ),
            ),
            if (_stepCompleted) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: c.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Great job!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBoard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border, width: 2),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: 16,
          itemBuilder: (ctx, idx) {
            final r = idx ~/ 4;
            final col = idx % 4;
            return _buildCell(r, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int r, int col) {
    final val = _board[r][col];
    final given = _isGiven[r][col];
    final isSelected = r == _selectedRow && col == _selectedCol;
    final isTarget = _step.targetRow == r && _step.targetCol == col;
    final shouldHighlight = isTarget &&
        (_step.action == TutorialAction.selectCell ||
            _step.action == TutorialAction.addNote);

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = c.selBg;
    } else if (shouldHighlight && !_stepCompleted) {
      bgColor = c.primary.withValues(alpha: _highlightAnimation.value);
    }

    final rightBorder = (col == 1)
        ? BorderSide(color: c.borderBox, width: 2)
        : BorderSide(color: c.border, width: 0.5);
    final bottomBorder = (r == 1)
        ? BorderSide(color: c.borderBox, width: 2)
        : BorderSide(color: c.border, width: 0.5);

    Widget cellContent = AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(right: rightBorder, bottom: bottomBorder),
        ),
        alignment: Alignment.center,
        child: val != 0
            ? Text(
                '$val',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: given ? c.givenColor : c.userColor,
                ),
              )
            : _notes[r][col].isNotEmpty
                ? _buildNotes(r, col)
                : null,
      ),
    );

    // Add pulse animation for target cells
    if (shouldHighlight && !_stepCompleted) {
      cellContent = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: cellContent,
      );
    }

    return GestureDetector(
      onTap: () => _onCellTap(r, col),
      child: cellContent,
    );
  }

  Widget _buildNotes(int r, int col) {
    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      children: List.generate(4, (i) {
        final n = i + 1;
        return Center(
          child: Text(
            _notes[r][col].contains(n) ? '$n' : '',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: c.noteColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Row(
      children: List.generate(4, (i) {
        final n = i + 1;
        final isTarget = _step.targetNumber == n &&
            (_step.action == TutorialAction.inputNumber ||
                _step.action == TutorialAction.addNote);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _onNumberTap(n),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isTarget && !_stepCompleted ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isTarget && !_stepCompleted
                            ? c.primary.withValues(alpha: 0.2)
                            : c.surface,
                        border: Border.all(
                          color: isTarget && !_stepCompleted ? c.primary : c.border,
                          width: isTarget && !_stepCompleted ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isTarget && !_stepCompleted ? c.primary : c.text,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActions() {
    final isNotesTarget =
        _step.action == TutorialAction.toggleNotes && !_stepCompleted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _onNotesToggle,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isNotesTarget ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _notesMode
                        ? c.primary
                        : isNotesTarget
                            ? c.primary.withValues(alpha: 0.2)
                            : c.surface,
                    border: Border.all(
                      color: _notesMode || isNotesTarget ? c.primary : c.border,
                      width: isNotesTarget ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '✏️',
                        style: TextStyle(
                          fontSize: 18,
                          color: _notesMode ? Colors.white : c.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _notesMode ? Colors.white : c.text,
                        ),
                      ),
                      if (_notesMode) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onComplete();
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F6EF7).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start Playing!',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Text(
        'Skip Tutorial',
        style: TextStyle(
          fontSize: 14,
          color: c.textMuted,
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String instruction;
  final int? targetRow;
  final int? targetCol;
  final int? targetNumber;
  final TutorialAction action;

  const TutorialStep({
    required this.title,
    required this.instruction,
    this.targetRow,
    this.targetCol,
    this.targetNumber,
    required this.action,
  });
}

enum TutorialAction {
  selectCell,
  inputNumber,
  toggleNotes,
  addNote,
  complete,
}
