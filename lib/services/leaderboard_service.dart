import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String deviceId;
  final int time; // seconds
  final int mistakes;
  final int timestamp;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.time,
    required this.mistakes,
    required this.timestamp,
  });

  factory LeaderboardEntry.fromJson(String id, Map<dynamic, dynamic> json) {
    return LeaderboardEntry(
      id: id,
      name: json['name'] ?? 'Unknown',
      deviceId: json['deviceId'] ?? '',
      time: json['time'] ?? 0,
      mistakes: json['mistakes'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'deviceId': deviceId,
    'time': time,
    'mistakes': mistakes,
    'timestamp': timestamp,
  };
}

class TournamentInfo {
  final String id;
  final String difficulty;
  final int seed;
  final int startTime;
  final int endTime;
  final String status; // 'active', 'ended'

  TournamentInfo({
    required this.id,
    required this.difficulty,
    required this.seed,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TournamentInfo.fromJson(String id, Map<dynamic, dynamic> json) {
    return TournamentInfo(
      id: id,
      difficulty: json['difficulty'] ?? 'medium',
      seed: json['seed'] ?? 0,
      startTime: json['startTime'] ?? 0,
      endTime: json['endTime'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }

  bool get isActive {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startTime && now <= endTime;
  }

  Duration get timeRemaining {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= endTime) return Duration.zero;
    return Duration(milliseconds: endTime - now);
  }
}

class TournamentEntry {
  final String deviceId;
  final String name;
  final int time;
  final int mistakes;
  final int submittedAt;

  TournamentEntry({
    required this.deviceId,
    required this.name,
    required this.time,
    required this.mistakes,
    required this.submittedAt,
  });

  factory TournamentEntry.fromJson(String deviceId, Map<dynamic, dynamic> json) {
    return TournamentEntry(
      deviceId: deviceId,
      name: json['name'] ?? 'Unknown',
      time: json['time'] ?? 0,
      mistakes: json['mistakes'] ?? 0,
      submittedAt: json['submittedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
    'mistakes': mistakes,
    'submittedAt': submittedAt,
  };
}

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  DatabaseReference? _dbRef;

  DatabaseReference get _db {
    _dbRef ??= FirebaseDatabase.instance.ref();
    return _dbRef!;
  }

  /// Check if Firebase is available
  bool get isAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOBAL LEADERBOARDS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submit a score to the global leaderboard
  Future<bool> submitScore({
    required String difficulty,
    required String name,
    required String deviceId,
    required int time,
    required int mistakes,
  }) async {
    if (!isAvailable) {
      debugPrint('LeaderboardService: Firebase not available, skipping score submit');
      return false;
    }

    try {
      debugPrint('LeaderboardService: Submitting score - $name, $difficulty, ${time}s, $mistakes mistakes');

      final ref = _db.child('leaderboards/$difficulty').push();
      await ref.set({
        'name': name,
        'deviceId': deviceId,
        'time': time,
        'mistakes': mistakes,
        'timestamp': ServerValue.timestamp,
      });

      debugPrint('LeaderboardService: Score submitted successfully!');

      // Clean up old entries - keep only top 500
      await _pruneLeaderboard(difficulty);
      return true;
    } catch (e) {
      debugPrint('LeaderboardService: Failed to submit score: $e');
      return false;
    }
  }

  /// Get top scores for a difficulty
  Future<List<LeaderboardEntry>> getTopScores(String difficulty, {int limit = 100}) async {
    if (!isAvailable) {
      debugPrint('LeaderboardService: Firebase not available, returning empty leaderboard');
      return [];
    }

    try {
      debugPrint('LeaderboardService: Fetching top scores for $difficulty...');

      final snapshot = await _db
          .child('leaderboards/$difficulty')
          .orderByChild('time')
          .limitToFirst(limit)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        debugPrint('LeaderboardService: No scores found for $difficulty');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      debugPrint('LeaderboardService: Found ${data.length} entries for $difficulty');

      final entries = data.entries
          .map((e) => LeaderboardEntry.fromJson(e.key.toString(), e.value as Map<dynamic, dynamic>))
          .toList();

      // Sort by time (ascending), then by mistakes (ascending)
      entries.sort((a, b) {
        final timeCompare = a.time.compareTo(b.time);
        if (timeCompare != 0) return timeCompare;
        return a.mistakes.compareTo(b.mistakes);
      });

      return entries;
    } catch (e) {
      debugPrint('LeaderboardService: Failed to get leaderboard: $e');
      return [];
    }
  }

  /// Get user's rank on leaderboard
  Future<int?> getUserRank(String difficulty, String deviceId) async {
    try {
      final entries = await getTopScores(difficulty, limit: 500);
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].deviceId == deviceId) {
          return i + 1;
        }
      }
      return null; // Not on leaderboard
    } catch (e) {
      return null;
    }
  }

  /// Get user's best score on leaderboard
  Future<LeaderboardEntry?> getUserBestScore(String difficulty, String deviceId) async {
    try {
      final snapshot = await _db
          .child('leaderboards/$difficulty')
          .orderByChild('deviceId')
          .equalTo(deviceId)
          .limitToFirst(1)
          .get();

      if (!snapshot.exists || snapshot.value == null) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      if (data.isEmpty) return null;

      final entry = data.entries.first;
      return LeaderboardEntry.fromJson(entry.key, entry.value);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pruneLeaderboard(String difficulty) async {
    try {
      final snapshot = await _db
          .child('leaderboards/$difficulty')
          .orderByChild('time')
          .get();

      if (!snapshot.exists || snapshot.value == null) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      if (data.length <= 500) return;

      // Get all entries sorted by time
      final entries = data.entries.toList();
      entries.sort((a, b) => (a.value['time'] as int).compareTo(b.value['time'] as int));

      // Remove entries beyond 500
      for (int i = 500; i < entries.length; i++) {
        await _db.child('leaderboards/$difficulty/${entries[i].key}').remove();
      }
    } catch (e) {
      // Ignore pruning errors
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOURNAMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get current daily tournament (creates one if doesn't exist)
  Future<TournamentInfo?> getDailyTournament() async {
    final today = _getTodayString();
    final tournamentId = 'daily_$today';

    try {
      final snapshot = await _db.child('tournaments/$tournamentId/info').get();

      if (snapshot.exists && snapshot.value != null) {
        return TournamentInfo.fromJson(tournamentId, snapshot.value as Map);
      }

      // Create new daily tournament
      return await _createDailyTournament(tournamentId, today);
    } catch (e) {
      print('Failed to get daily tournament: $e');
      return null;
    }
  }

  Future<TournamentInfo?> _createDailyTournament(String id, String date) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Generate seed from date
      final seed = date.hashCode.abs();

      // Rotate difficulty based on day of week
      final difficulties = ['easy', 'medium', 'hard', 'medium'];
      final difficulty = difficulties[now.weekday % difficulties.length];

      final info = {
        'difficulty': difficulty,
        'seed': seed,
        'startTime': startOfDay.millisecondsSinceEpoch,
        'endTime': endOfDay.millisecondsSinceEpoch,
        'status': 'active',
      };

      await _db.child('tournaments/$id/info').set(info);

      return TournamentInfo.fromJson(id, info);
    } catch (e) {
      print('Failed to create daily tournament: $e');
      return null;
    }
  }

  /// Get current weekly tournament
  Future<TournamentInfo?> getWeeklyTournament() async {
    final weekId = _getWeekString();
    final tournamentId = 'weekly_$weekId';

    try {
      final snapshot = await _db.child('tournaments/$tournamentId/info').get();

      if (snapshot.exists && snapshot.value != null) {
        return TournamentInfo.fromJson(tournamentId, snapshot.value as Map);
      }

      // Create new weekly tournament
      return await _createWeeklyTournament(tournamentId, weekId);
    } catch (e) {
      print('Failed to get weekly tournament: $e');
      return null;
    }
  }

  Future<TournamentInfo?> _createWeeklyTournament(String id, String weekId) async {
    try {
      final now = DateTime.now();
      // Start of week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endDate = startDate.add(const Duration(days: 7));

      // Generate seed from week
      final seed = weekId.hashCode.abs();

      final info = {
        'difficulty': 'hard', // Weekly is always hard
        'seed': seed,
        'startTime': startDate.millisecondsSinceEpoch,
        'endTime': endDate.millisecondsSinceEpoch,
        'status': 'active',
      };

      await _db.child('tournaments/$id/info').set(info);

      return TournamentInfo.fromJson(id, info);
    } catch (e) {
      print('Failed to create weekly tournament: $e');
      return null;
    }
  }

  /// Submit tournament entry
  Future<bool> submitTournamentEntry({
    required String tournamentId,
    required String deviceId,
    required String name,
    required int time,
    required int mistakes,
  }) async {
    try {
      // Check if already submitted
      final existing = await _db
          .child('tournaments/$tournamentId/entries/$deviceId')
          .get();

      if (existing.exists && existing.value != null) {
        final existingTime = (existing.value as Map)['time'] as int;
        // Only update if better time
        if (time >= existingTime) {
          return false; // Already have a better score
        }
      }

      await _db.child('tournaments/$tournamentId/entries/$deviceId').set({
        'name': name,
        'time': time,
        'mistakes': mistakes,
        'submittedAt': ServerValue.timestamp,
      });

      return true;
    } catch (e) {
      print('Failed to submit tournament entry: $e');
      return false;
    }
  }

  /// Get tournament leaderboard
  Future<List<TournamentEntry>> getTournamentLeaderboard(String tournamentId, {int limit = 100}) async {
    try {
      final snapshot = await _db
          .child('tournaments/$tournamentId/entries')
          .orderByChild('time')
          .limitToFirst(limit)
          .get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      final entries = data.entries
          .map((e) => TournamentEntry.fromJson(e.key, e.value))
          .toList();

      // Sort by time
      entries.sort((a, b) => a.time.compareTo(b.time));

      return entries;
    } catch (e) {
      print('Failed to get tournament leaderboard: $e');
      return [];
    }
  }

  /// Check if user has entered tournament
  Future<TournamentEntry?> getUserTournamentEntry(String tournamentId, String deviceId) async {
    try {
      final snapshot = await _db
          .child('tournaments/$tournamentId/entries/$deviceId')
          .get();

      if (!snapshot.exists || snapshot.value == null) return null;

      return TournamentEntry.fromJson(deviceId, snapshot.value as Map);
    } catch (e) {
      return null;
    }
  }

  /// Get user's rank in tournament
  Future<int?> getUserTournamentRank(String tournamentId, String deviceId) async {
    try {
      final entries = await getTournamentLeaderboard(tournamentId, limit: 500);
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].deviceId == deviceId) {
          return i + 1;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getWeekString() {
    final now = DateTime.now();
    // ISO week number
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;
    final weekNumber = ((dayOfYear - now.weekday + 10) / 7).floor();
    return '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
