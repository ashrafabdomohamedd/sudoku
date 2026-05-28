import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'interactive_tutorial.dart';

class LearningModal extends StatefulWidget {
  final AppColorScheme colors;
  final VoidCallback? onTutorialComplete;

  const LearningModal({super.key, required this.colors, this.onTutorialComplete});

  @override
  State<LearningModal> createState() => _LearningModalState();
}

class _LearningModalState extends State<LearningModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AppColorScheme get c => widget.colors;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            // Interactive Tutorial Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildTutorialButton(context),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: c.primary,
                unselectedLabelColor: c.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Basics'),
                  Tab(text: 'Techniques'),
                  Tab(text: 'Tips'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicsTab(),
                  _buildTechniquesTab(),
                  _buildTipsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'How to Play',
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
    );
  }

  Widget _buildTutorialButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => InteractiveTutorial(
            colors: c,
            onComplete: () {
              widget.onTutorialComplete?.call();
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F6EF7).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interactive Tutorial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Learn by playing a mini puzzle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            '🎯',
            'The Goal',
            'Fill every row, column, and 3x3 box with the numbers 1-9, without repeating any number.',
          ),
          const SizedBox(height: 12),
          _sectionCard(
            '📐',
            'The Rules',
            '• Each row must contain 1-9 (no repeats)\n'
            '• Each column must contain 1-9 (no repeats)\n'
            '• Each 3x3 box must contain 1-9 (no repeats)',
          ),
          const SizedBox(height: 12),
          _sectionCard(
            '🎮',
            'Controls',
            '• Tap a cell to select it\n'
            '• Tap a number to fill the cell\n'
            '• Use Notes mode to mark possible numbers\n'
            '• Use Undo to fix mistakes\n'
            '• Use Hint when stuck (use sparingly!)',
          ),
          const SizedBox(height: 12),
          _sectionCard(
            '⌨️',
            'Keyboard Shortcuts',
            '• 1-9: Enter numbers\n'
            '• Arrow keys: Move selection\n'
            '• N: Toggle notes mode\n'
            '• Z: Undo\n'
            '• H: Get hint\n'
            '• Space: Pause/Resume',
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _techniqueCard(
            '1️⃣',
            'Single Candidate',
            'If a cell can only contain one possible number, fill it in!',
            'Look for cells where 8 of the 9 numbers are already in the same row, column, or box.',
            DifficultyLevel.beginner,
          ),
          const SizedBox(height: 12),
          _techniqueCard(
            '🔍',
            'Hidden Single',
            'If a number can only go in one cell within a row, column, or box, place it there.',
            'Scan each row/column/box and ask "Where can this number go?"',
            DifficultyLevel.beginner,
          ),
          const SizedBox(height: 12),
          _techniqueCard(
            '👀',
            'Scanning',
            'Look across rows and down columns to eliminate possibilities.',
            'If 7 is in row 1 and row 2 of a box, it must be in row 3 of that box.',
            DifficultyLevel.intermediate,
          ),
          const SizedBox(height: 12),
          _techniqueCard(
            '✏️',
            'Pencil Marks',
            'Use notes to track possible numbers for each cell.',
            'Write small numbers in cells to remember what could go there.',
            DifficultyLevel.intermediate,
          ),
          const SizedBox(height: 12),
          _techniqueCard(
            '👯',
            'Naked Pairs',
            'If two cells in a group can only contain the same two numbers, eliminate those numbers from other cells.',
            'Example: If cells A and B can only be 4 or 7, no other cell in that row/column/box can be 4 or 7.',
            DifficultyLevel.advanced,
          ),
          const SizedBox(height: 12),
          _techniqueCard(
            '🔗',
            'Pointing Pairs',
            'If a number in a box is confined to one row/column, eliminate it from that row/column in other boxes.',
            'Use the constraint of boxes to limit possibilities in rows/columns.',
            DifficultyLevel.advanced,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tipCard(
            '🌟',
            'Start with Easy',
            'Begin with Easy puzzles to learn patterns before moving to harder difficulties.',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '✏️',
            'Use Notes Wisely',
            'Notes are your friend! Mark possible numbers to avoid losing track of your deductions.',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '🔢',
            'Count Numbers',
            'Look at which numbers appear most. Numbers that appear 8 times only have one spot left!',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '📦',
            'Focus on Boxes',
            'Solving 3x3 boxes often reveals numbers in adjacent boxes.',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '🚫',
            'Avoid Guessing',
            "Don't guess! Every cell has a logical solution. If you're stuck, use notes more thoroughly.",
          ),
          const SizedBox(height: 12),
          _tipCard(
            '⏸️',
            'Take Breaks',
            'If stuck, pause and come back later. Fresh eyes often spot what you missed.',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '📅',
            'Daily Challenges',
            'Play the daily challenge to build a streak and improve consistently.',
          ),
          const SizedBox(height: 12),
          _tipCard(
            '🏆',
            'Track Progress',
            'Watch your statistics improve over time. Celebrate your best times!',
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String emoji, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: c.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _techniqueCard(String emoji, String title, String description, String howTo, DifficultyLevel level) {
    final levelColors = {
      DifficultyLevel.beginner: const Color(0xFF10B981),
      DifficultyLevel.intermediate: const Color(0xFF3B82F6),
      DifficultyLevel.advanced: const Color(0xFFF59E0B),
    };
    final levelNames = {
      DifficultyLevel.beginner: 'Beginner',
      DifficultyLevel.intermediate: 'Intermediate',
      DifficultyLevel.advanced: 'Advanced',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColors[level]!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  levelNames[level]!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: levelColors[level],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: c.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    howTo,
                    style: TextStyle(
                      fontSize: 12,
                      color: c.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String emoji, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum DifficultyLevel { beginner, intermediate, advanced }
