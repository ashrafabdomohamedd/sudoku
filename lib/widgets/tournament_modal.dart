import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/game_store.dart';
import '../state/game_state.dart';
import '../services/leaderboard_service.dart';
import '../screens/game_screen.dart';

class TournamentModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;
  final VoidCallback? onStartTournament;

  const TournamentModal({
    super.key,
    required this.store,
    required this.colors,
    this.onStartTournament,
  });

  @override
  State<TournamentModal> createState() => _TournamentModalState();
}

class _TournamentModalState extends State<TournamentModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _service = LeaderboardService();

  TournamentInfo? _dailyTournament;
  TournamentInfo? _weeklyTournament;
  List<TournamentEntry> _dailyEntries = [];
  List<TournamentEntry> _weeklyEntries = [];
  TournamentEntry? _userDailyEntry;
  TournamentEntry? _userWeeklyEntry;
  int? _userDailyRank;
  int? _userWeeklyRank;
  bool _loading = true;

  Timer? _countdownTimer;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTournaments();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadTournaments() async {
    setState(() => _loading = true);

    final daily = await _service.getDailyTournament();
    final weekly = await _service.getWeeklyTournament();

    List<TournamentEntry> dailyEntries = [];
    List<TournamentEntry> weeklyEntries = [];
    TournamentEntry? userDaily;
    TournamentEntry? userWeekly;
    int? dailyRank;
    int? weeklyRank;

    if (daily != null) {
      dailyEntries = await _service.getTournamentLeaderboard(daily.id);
      userDaily = await _service.getUserTournamentEntry(daily.id, store.deviceId ?? '');
      dailyRank = await _service.getUserTournamentRank(daily.id, store.deviceId ?? '');
    }

    if (weekly != null) {
      weeklyEntries = await _service.getTournamentLeaderboard(weekly.id);
      userWeekly = await _service.getUserTournamentEntry(weekly.id, store.deviceId ?? '');
      weeklyRank = await _service.getUserTournamentRank(weekly.id, store.deviceId ?? '');
    }

    if (mounted) {
      setState(() {
        _dailyTournament = daily;
        _weeklyTournament = weekly;
        _dailyEntries = dailyEntries;
        _weeklyEntries = weeklyEntries;
        _userDailyEntry = userDaily;
        _userWeeklyEntry = userWeekly;
        _userDailyRank = dailyRank;
        _userWeeklyRank = weeklyRank;
        _loading = false;
      });
    }
  }

  void _startDailyTournament() {
    if (_dailyTournament == null) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    // Create game with tournament seed
    final game = GameState();
    game.newGame(
      _dailyTournament!.difficulty,
      seed: _dailyTournament!.seed,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          store: store,
          game: game,
          tournamentId: _dailyTournament!.id,
        ),
      ),
    );
  }

  void _startWeeklyTournament() {
    if (_weeklyTournament == null) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    final game = GameState();
    game.newGame(
      _weeklyTournament!.difficulty,
      seed: _weeklyTournament!.seed,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          store: store,
          game: game,
          tournamentId: _weeklyTournament!.id,
        ),
      ),
    );
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
            _buildTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDailyTab(),
                        _buildWeeklyTab(),
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
              const Text('🏅', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'Tournaments',
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

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: c.primary,
        unselectedLabelColor: c.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
          Tab(text: '📅 Daily'),
          Tab(text: '📆 Weekly'),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    if (_dailyTournament == null) {
      return _buildNoTournament();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTournamentCard(
            tournament: _dailyTournament!,
            userEntry: _userDailyEntry,
            userRank: _userDailyRank,
            onStart: _startDailyTournament,
            isDaily: true,
          ),
          const SizedBox(height: 16),
          _buildLeaderboardSection(_dailyEntries, _dailyTournament!.id),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (_weeklyTournament == null) {
      return _buildNoTournament();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTournamentCard(
            tournament: _weeklyTournament!,
            userEntry: _userWeeklyEntry,
            userRank: _userWeeklyRank,
            onStart: _startWeeklyTournament,
            isDaily: false,
          ),
          const SizedBox(height: 16),
          _buildLeaderboardSection(_weeklyEntries, _weeklyTournament!.id),
        ],
      ),
    );
  }

  Widget _buildNoTournament() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏅', style: TextStyle(fontSize: 48, color: c.textMuted)),
          const SizedBox(height: 16),
          Text(
            'No tournament available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon!',
            style: TextStyle(fontSize: 14, color: c.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard({
    required TournamentInfo tournament,
    required TournamentEntry? userEntry,
    required int? userRank,
    required VoidCallback onStart,
    required bool isDaily,
  }) {
    final timeRemaining = tournament.timeRemaining;
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;

    final difficultyEmoji = {
      'easy': '🟢',
      'medium': '🟡',
      'hard': '🟠',
      'expert': '🔴',
    }[tournament.difficulty] ?? '🟡';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDaily
              ? [const Color(0xFF4F6EF7), const Color(0xFF7C3AED)]
              : [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDaily ? const Color(0xFF4F6EF7) : const Color(0xFFF59E0B))
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDaily ? 'Daily Challenge' : 'Weekly Challenge',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(difficultyEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.difficulty[0].toUpperCase()}${tournament.difficulty.substring(1)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Time Left',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      isDaily
                          ? '${hours}h ${minutes}m'
                          : '${timeRemaining.inDays}d ${hours % 24}h',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (userEntry != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your Best: ${_service.formatTime(userEntry.time)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (userRank != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rank #$userRank',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                userEntry != null ? 'Try Again' : 'Start Challenge',
                style: TextStyle(
                  fontSize: 15,
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

  Widget _buildLeaderboardSection(List<TournamentEntry> entries, String tournamentId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            const Spacer(),
            Text(
              '${entries.length} entries',
              style: TextStyle(
                fontSize: 12,
                color: c.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No entries yet. Be the first!',
                style: TextStyle(color: c.textMuted),
              ),
            ),
          )
        else
          ...entries.take(10).toList().asMap().entries.map((entry) {
            return _buildLeaderboardEntry(entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildLeaderboardEntry(int index, TournamentEntry entry) {
    final rank = index + 1;
    final isUser = entry.deviceId == store.deviceId;

    String? medalEmoji;
    if (rank == 1) medalEmoji = '🥇';
    else if (rank == 2) medalEmoji = '🥈';
    else if (rank == 3) medalEmoji = '🥉';

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
            child: medalEmoji != null
                ? Text(medalEmoji, style: const TextStyle(fontSize: 18))
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.textMuted,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _service.formatTime(entry.time),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
        ],
      ),
    );
  }
}
