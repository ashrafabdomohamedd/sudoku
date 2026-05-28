import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';
import '../state/game_store.dart';
import '../theme/app_theme.dart';

class AchievementsModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const AchievementsModal({
    super.key,
    required this.store,
    required this.colors,
  });

  @override
  State<AchievementsModal> createState() => _AchievementsModalState();
}

class _AchievementsModalState extends State<AchievementsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory _selectedCategory = AchievementCategory.milestone;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  final List<AchievementCategory> _categories = AchievementCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = store.unlockedCount;
    final totalCount = store.totalAchievements;
    final progress = store.achievementProgress;

    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: c.text,
                            ),
                          ),
                        ],
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
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$unlockedCount / $totalCount Unlocked',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: c.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: c.surface2,
                          valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Category tabs
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: c.primary,
                unselectedLabelColor: c.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: c.primary,
                dividerColor: Colors.transparent,
                tabAlignment: TabAlignment.start,
                tabs: _categories.map((cat) {
                  final catAchievements = Achievements.getByCategory(cat);
                  final unlockedInCat = catAchievements.where((a) => store.hasAchievement(a.id)).length;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getCategoryIcon(cat)),
                        const SizedBox(width: 6),
                        Text(_getCategoryName(cat)),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.surface2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unlockedInCat/${catAchievements.length}',
                            style: TextStyle(fontSize: 9, color: c.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Achievement list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((cat) {
                  final achievements = Achievements.getByCategory(cat);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      final isUnlocked = store.hasAchievement(achievement.id);
                      return _buildAchievementCard(achievement, isUnlocked);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    final isSecret = achievement.isSecret && !isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? c.surface : c.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? c.primary : c.border,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: c.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? c.primary.withValues(alpha: 0.12)
                  : c.surface2,
              borderRadius: BorderRadius.circular(12),
              border: isUnlocked
                  ? Border.all(color: c.primary.withValues(alpha: 0.3))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              isSecret ? '❓' : achievement.icon,
              style: TextStyle(
                fontSize: 24,
                color: isUnlocked ? null : c.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSecret ? '???' : achievement.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked ? c.text : c.textMuted,
                        ),
                      ),
                    ),
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? achievement.rarityColor.withValues(alpha: 0.15)
                            : c.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        achievement.rarityName,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked ? achievement.rarityColor : c.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isSecret ? 'Complete a secret challenge to unlock' : achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Unlock indicator
          if (isUnlocked)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.primary.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: c.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.lock_outline, size: 14, color: c.textMuted),
            ),
        ],
      ),
    );
  }

  String _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone:
        return '🎯';
      case AchievementCategory.perfection:
        return '💎';
      case AchievementCategory.speed:
        return '⚡';
      case AchievementCategory.streak:
        return '🔥';
      case AchievementCategory.difficulty:
        return '🏔️';
      case AchievementCategory.special:
        return '✨';
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone:
        return 'Milestones';
      case AchievementCategory.perfection:
        return 'Perfection';
      case AchievementCategory.speed:
        return 'Speed';
      case AchievementCategory.streak:
        return 'Streaks';
      case AchievementCategory.difficulty:
        return 'Difficulty';
      case AchievementCategory.special:
        return 'Special';
    }
  }
}

/// Widget to show achievement unlock notification
class AchievementUnlockNotification extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockNotification({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              achievement.rarityColor.withValues(alpha: 0.9),
              achievement.rarityColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: achievement.rarityColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(achievement.icon, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
