import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';
import '../state/game_store.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';
import '../services/leaderboard_service.dart';
import '../screens/game_screen.dart';

class AchievementsModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;
  final int initialTab;

  const AchievementsModal({
    super.key,
    required this.store,
    required this.colors,
    this.initialTab = 0,
  });

  @override
  State<AchievementsModal> createState() => _AchievementsModalState();
}

class _AchievementsModalState extends State<AchievementsModal>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _mainTabController.dispose();
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
            _buildHeader(),
            _buildMainTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  _AchievementsTab(store: store, colors: c),
                  _LeaderboardTab(store: store, colors: c),
                  _TournamentsTab(store: store, colors: c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'Compete',
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

  Widget _buildMainTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _mainTabController,
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
          Tab(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎖️', style: TextStyle(fontSize: 14)),
              SizedBox(width: 2),
              FittedBox(child: Text('Achievements')),
            ],
          )),
          Tab(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📊', style: TextStyle(fontSize: 14)),
              SizedBox(width: 2),
              FittedBox(child: Text('Leaderboard')),
            ],
          )),
          Tab(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏅', style: TextStyle(fontSize: 14)),
              SizedBox(width: 2),
              FittedBox(child: Text('Tournaments')),
            ],
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACHIEVEMENTS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _AchievementsTab extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const _AchievementsTab({required this.store, required this.colors});

  @override
  State<_AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<_AchievementsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AchievementCategory> _categories = AchievementCategory.values;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
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

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
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
                  minHeight: 8,
                  backgroundColor: c.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              ),
            ],
          ),
        ),
        // Category tabs
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: c.primary,
            unselectedLabelColor: c.textMuted,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
                    const SizedBox(width: 4),
                    Text(_getCategoryName(cat)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$unlockedInCat/${catAchievements.length}',
                        style: TextStyle(fontSize: 8, color: c.textMuted),
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    final isSecret = achievement.isSecret && !isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? c.surface : c.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? c.primary : c.border,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked ? c.primary.withValues(alpha: 0.12) : c.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              isSecret ? '❓' : achievement.icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSecret ? '???' : achievement.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? c.text : c.textMuted,
                  ),
                ),
                Text(
                  isSecret ? 'Complete a secret challenge' : achievement.description,
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: c.primary, size: 22)
          else
            Icon(Icons.lock_outline, color: c.textMuted, size: 18),
        ],
      ),
    );
  }

  String _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone: return '🎯';
      case AchievementCategory.perfection: return '💎';
      case AchievementCategory.speed: return '⚡';
      case AchievementCategory.streak: return '🔥';
      case AchievementCategory.difficulty: return '🏔️';
      case AchievementCategory.special: return '✨';
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone: return 'Milestones';
      case AchievementCategory.perfection: return 'Perfection';
      case AchievementCategory.speed: return 'Speed';
      case AchievementCategory.streak: return 'Streaks';
      case AchievementCategory.difficulty: return 'Difficulty';
      case AchievementCategory.special: return 'Special';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEADERBOARD TAB
// ═══════════════════════════════════════════════════════════════════════════

class _LeaderboardTab extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const _LeaderboardTab({required this.store, required this.colors});

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _service = LeaderboardService();
  final List<String> _difficulties = ['easy', 'medium', 'hard', 'expert'];

  List<LeaderboardEntry> _entries = [];
  bool _loading = true;
  int? _userRank;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadLeaderboard();
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    final diff = _difficulties[_tabController.index];
    final entries = await _service.getTopScores(diff);
    final rank = await _service.getUserRank(diff, store.deviceId ?? '');

    if (mounted) {
      setState(() {
        _entries = entries;
        _userRank = rank;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Difficulty tabs
        Container(
          height: 36,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: c.primary,
            unselectedLabelColor: c.textMuted,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorPadding: const EdgeInsets.all(3),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
              Tab(text: 'Expert'),
            ],
          ),
        ),
        // User rank banner
        if (_userRank != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#$_userRank',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your Rank',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
                Text(
                  store.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        // Leaderboard list
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: c.primary))
              : _entries.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadLeaderboard,
                      color: c.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _entries.length,
                        itemBuilder: (ctx, i) => _buildEntry(i, _entries[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isFirebaseAvailable = _service.isAvailable;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isFirebaseAvailable ? '🏆' : '⚠️', style: TextStyle(fontSize: 40, color: c.textMuted)),
          const SizedBox(height: 12),
          Text(
            isFirebaseAvailable ? 'No scores yet!' : 'Leaderboard Unavailable',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text),
          ),
          const SizedBox(height: 4),
          Text(
            isFirebaseAvailable
                ? 'Be the first to complete a puzzle'
                : 'Check your internet connection',
            style: TextStyle(fontSize: 13, color: c.textMuted),
          ),
          if (!isFirebaseAvailable) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadLeaderboard,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntry(int index, LeaderboardEntry entry) {
    final rank = index + 1;
    final isUser = entry.deviceId == store.deviceId;
    String? medal;
    if (rank == 1) medal = '🥇';
    else if (rank == 2) medal = '🥈';
    else if (rank == 3) medal = '🥉';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser ? c.primary.withValues(alpha: 0.1) : c.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: isUser ? Border.all(color: c.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text('$rank', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(entry.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text), overflow: TextOverflow.ellipsis),
          ),
          Text(_service.formatTime(entry.time), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.text)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TOURNAMENTS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _TournamentsTab extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const _TournamentsTab({required this.store, required this.colors});

  @override
  State<_TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends State<_TournamentsTab> {
  final LeaderboardService _service = LeaderboardService();
  Timer? _countdownTimer;

  TournamentInfo? _dailyTournament;
  TournamentInfo? _weeklyTournament;
  TournamentEntry? _userDailyEntry;
  TournamentEntry? _userWeeklyEntry;
  int? _userDailyRank;
  int? _userWeeklyRank;
  bool _loading = true;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    setState(() => _loading = true);

    final daily = await _service.getDailyTournament();
    final weekly = await _service.getWeeklyTournament();

    TournamentEntry? userDaily;
    TournamentEntry? userWeekly;
    int? dailyRank;
    int? weeklyRank;

    if (daily != null) {
      userDaily = await _service.getUserTournamentEntry(daily.id, store.deviceId ?? '');
      dailyRank = await _service.getUserTournamentRank(daily.id, store.deviceId ?? '');
    }

    if (weekly != null) {
      userWeekly = await _service.getUserTournamentEntry(weekly.id, store.deviceId ?? '');
      weeklyRank = await _service.getUserTournamentRank(weekly.id, store.deviceId ?? '');
    }

    if (mounted) {
      setState(() {
        _dailyTournament = daily;
        _weeklyTournament = weekly;
        _userDailyEntry = userDaily;
        _userWeeklyEntry = userWeekly;
        _userDailyRank = dailyRank;
        _userWeeklyRank = weeklyRank;
        _loading = false;
      });
    }
  }

  void _startTournament(TournamentInfo tournament) {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    final game = GameState();
    game.newGame(tournament.difficulty, seed: tournament.seed);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          store: store,
          game: game,
          tournamentId: tournament.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_dailyTournament != null)
            _buildTournamentCard(
              tournament: _dailyTournament!,
              userEntry: _userDailyEntry,
              userRank: _userDailyRank,
              isDaily: true,
            ),
          const SizedBox(height: 12),
          if (_weeklyTournament != null)
            _buildTournamentCard(
              tournament: _weeklyTournament!,
              userEntry: _userWeeklyEntry,
              userRank: _userWeeklyRank,
              isDaily: false,
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard({
    required TournamentInfo tournament,
    required TournamentEntry? userEntry,
    required int? userRank,
    required bool isDaily,
  }) {
    final timeRemaining = tournament.timeRemaining;
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;

    final diffEmoji = {'easy': '🟢', 'medium': '🟡', 'hard': '🟠', 'expert': '🔴'}[tournament.difficulty] ?? '🟡';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDaily
              ? [const Color(0xFF4F6EF7), const Color(0xFF7C3AED)]
              : [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDaily ? '📅 Daily Challenge' : '📆 Weekly Challenge',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(diffEmoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.difficulty[0].toUpperCase()}${tournament.difficulty.substring(1)}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDaily ? '${hours}h ${minutes}m left' : '${timeRemaining.inDays}d ${hours % 24}h left',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          if (userEntry != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Your Best: ${_service.formatTime(userEntry.time)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const Spacer(),
                  if (userRank != null)
                    Text(
                      'Rank #$userRank',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _startTournament(tournament),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                userEntry != null ? 'Try Again' : 'Start Challenge',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDaily ? const Color(0xFF4F6EF7) : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACHIEVEMENT UNLOCK NOTIFICATION (unchanged)
// ═══════════════════════════════════════════════════════════════════════════

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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
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
