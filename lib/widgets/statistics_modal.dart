import 'package:flutter/material.dart';
import '../state/game_store.dart';
import '../theme/app_theme.dart';

class StatisticsModal extends StatelessWidget {
  final GameStore store;
  final AppColorScheme colors;

  const StatisticsModal({
    super.key,
    required this.store,
    required this.colors,
  });

  AppColorScheme get c => colors;

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
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(),
                    const SizedBox(height: 20),
                    _buildDifficultySection(),
                    const SizedBox(height: 20),
                    _buildBestTimesSection(),
                    const SizedBox(height: 20),
                    _buildStreaksSection(),
                    const SizedBox(height: 20),
                    _buildMiscSection(),
                  ],
                ),
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
              const Text('📊', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'Statistics',
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
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Overview'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.primary.withValues(alpha: 0.1), c.primary.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _overviewStat(store.played.toString(), 'Games\nPlayed', Icons.grid_3x3_rounded)),
                  _verticalDivider(),
                  Expanded(child: _overviewStat(store.won.toString(), 'Games\nWon', Icons.emoji_events_outlined)),
                  _verticalDivider(),
                  Expanded(child: _overviewStat(store.winRate, 'Win\nRate', Icons.percent_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 20, color: c.primary),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Time Played',
                          style: TextStyle(fontSize: 11, color: c.textMuted),
                        ),
                        Text(
                          store.formatLongTime(store.totalPlayTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Avg. Time',
                          style: TextStyle(fontSize: 11, color: c.textMuted),
                        ),
                        Text(
                          store.formatTime(store.averageTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overviewStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: c.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: c.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: c.textMuted,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60,
      color: c.border,
    );
  }

  Widget _buildDifficultySection() {
    final difficulties = ['easy', 'medium', 'hard', 'expert'];
    final diffColors = {
      'easy': const Color(0xFF10B981),
      'medium': const Color(0xFF3B82F6),
      'hard': const Color(0xFFF59E0B),
      'expert': const Color(0xFFEF4444),
    };
    final diffIcons = {
      'easy': '🌱',
      'medium': '🔥',
      'hard': '💪',
      'expert': '🏆',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('By Difficulty'),
        const SizedBox(height: 12),
        ...difficulties.map((diff) {
          final stats = store.getStatsForDifficulty(diff);
          final color = diffColors[diff]!;
          final winRate = stats.winRate;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(diffIcons[diff]!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diff[0].toUpperCase() + diff.substring(1),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stats.played} played · ${stats.won} won',
                            style: TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(winRate * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        Text(
                          'win rate',
                          style: TextStyle(fontSize: 10, color: c.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Win rate bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: winRate,
                    minHeight: 8,
                    backgroundColor: c.surface2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 10),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat('Best', store.formatTime(stats.fastestTime), color),
                    _miniStat('Avg', store.formatTime(stats.averageTime), c.textMuted),
                    _miniStat('Total', store.formatTime(stats.totalTime), c.textMuted),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: c.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBestTimesSection() {
    final difficulties = ['easy', 'medium', 'hard', 'expert'];
    final hasAnyBestTime = difficulties.any((d) => store.bestTimes[d] != null);

    if (!hasAnyBestTime) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Best Times'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: difficulties.map((diff) {
              final time = store.bestTimes[diff];
              final hasTime = time != null;
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: hasTime ? c.primary.withValues(alpha: 0.1) : c.surface2,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: hasTime
                        ? Icon(Icons.emoji_events, color: c.primary, size: 24)
                        : Icon(Icons.lock_outline, color: c.textMuted, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diff[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasTime ? store.formatTime(time) : '--:--',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: hasTime ? c.text : c.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Daily Streaks'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      '${store.currentStreak}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Current\nStreak',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      '${store.longestStreak}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Longest\nStreak',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      '${store.dailyBestTimes.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Dailies\nCompleted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiscSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('More Stats'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: [
              _miscStatRow('💎', 'Perfect Games (0 mistakes)', '${store.perfectGames}'),
              _divider(),
              _miscStatRow('🧠', 'Games Without Hints', '${store.noHintGames}'),
              _divider(),
              _miscStatRow('🌐', 'Online Wins', '${store.onlineWins}'),
              _divider(),
              _miscStatRow('🏅', 'Achievements Unlocked', '${store.unlockedCount}/${store.totalAchievements}'),
              if (store.bestDifficulty != null) ...[
                _divider(),
                _miscStatRow('⭐', 'Best Difficulty', store.bestDifficulty![0].toUpperCase() + store.bestDifficulty!.substring(1)),
              ],
              if (store.mostPlayedDifficulty != null) ...[
                _divider(),
                _miscStatRow('🎯', 'Most Played', store.mostPlayedDifficulty![0].toUpperCase() + store.mostPlayedDifficulty!.substring(1)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _miscStatRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: c.text),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: c.border, height: 1);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: c.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}
