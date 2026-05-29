import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/game_store.dart';
import '../services/leaderboard_service.dart';

class LeaderboardModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;

  const LeaderboardModal({
    super.key,
    required this.store,
    required this.colors,
  });

  @override
  State<LeaderboardModal> createState() => _LeaderboardModalState();
}

class _LeaderboardModalState extends State<LeaderboardModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _service = LeaderboardService();

  String _selectedDifficulty = 'easy';
  List<LeaderboardEntry> _entries = [];
  bool _loading = true;
  int? _userRank;

  AppColorScheme get c => widget.colors;
  GameStore get store => widget.store;

  final List<String> _difficulties = ['easy', 'medium', 'hard', 'expert'];

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
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedDifficulty = _difficulties[_tabController.index];
    });
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);

    final entries = await _service.getTopScores(_selectedDifficulty);
    final rank = await _service.getUserRank(_selectedDifficulty, store.deviceId ?? '');

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
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTabs(),
            const SizedBox(height: 8),
            if (_userRank != null) _buildUserRank(),
            Expanded(child: _buildLeaderboard()),
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
                'Leaderboard',
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
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
          Tab(text: 'Easy'),
          Tab(text: 'Medium'),
          Tab(text: 'Hard'),
          Tab(text: 'Expert'),
        ],
      ),
    );
  }

  Widget _buildUserRank() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#$_userRank',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rank',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (store.bestTimes[_selectedDifficulty] != null)
            Text(
              _service.formatTime(store.bestTimes[_selectedDifficulty]!),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: c.primary),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🏆',
              style: TextStyle(fontSize: 48, color: c.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'No scores yet!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to complete a puzzle',
              style: TextStyle(
                fontSize: 14,
                color: c.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: c.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) => _buildEntry(index, _entries[index]),
      ),
    );
  }

  Widget _buildEntry(int index, LeaderboardEntry entry) {
    final rank = index + 1;
    final isUser = entry.deviceId == store.deviceId;

    Color? medalColor;
    String? medalEmoji;
    if (rank == 1) {
      medalColor = const Color(0xFFFFD700);
      medalEmoji = '🥇';
    } else if (rank == 2) {
      medalColor = const Color(0xFFC0C0C0);
      medalEmoji = '🥈';
    } else if (rank == 3) {
      medalColor = const Color(0xFFCD7F32);
      medalEmoji = '🥉';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? c.primary.withValues(alpha: 0.1) : c.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: isUser ? Border.all(color: c.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: medalEmoji != null
                ? Text(medalEmoji, style: const TextStyle(fontSize: 24))
                : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.mistakes > 0)
                  Text(
                    '${entry.mistakes} mistake${entry.mistakes != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          // Time
          Text(
            _service.formatTime(entry.time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: medalColor ?? c.text,
            ),
          ),
        ],
      ),
    );
  }
}
