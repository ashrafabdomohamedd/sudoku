import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class ScoreEntry {
  final String diff;
  final int time;
  final int mistakes;
  final String date;

  ScoreEntry({required this.diff, required this.time, required this.mistakes, required this.date});

  Map<String, dynamic> toJson() => {'diff': diff, 'time': time, 'mistakes': mistakes, 'date': date};
  factory ScoreEntry.fromJson(Map<String, dynamic> j) =>
      ScoreEntry(diff: j['diff'], time: j['time'], mistakes: j['mistakes'], date: j['date']);
}

class SavedGame {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  final List<List<int>> board;
  final List<List<bool>> isGiven;
  final List<List<List<int>>> notes;
  final String difficulty;
  final int seconds;
  final int mistakes;
  final List<String> hintCells;

  SavedGame({
    required this.puzzle,
    required this.solution,
    required this.board,
    required this.isGiven,
    required this.notes,
    required this.difficulty,
    required this.seconds,
    required this.mistakes,
    required this.hintCells,
  });

  Map<String, dynamic> toJson() => {
    'puzzle': puzzle,
    'solution': solution,
    'board': board,
    'isGiven': isGiven,
    'notes': notes,
    'difficulty': difficulty,
    'seconds': seconds,
    'mistakes': mistakes,
    'hintCells': hintCells,
  };

  factory SavedGame.fromJson(Map<String, dynamic> j) => SavedGame(
    puzzle: (j['puzzle'] as List).map((r) => List<int>.from(r)).toList(),
    solution: (j['solution'] as List).map((r) => List<int>.from(r)).toList(),
    board: (j['board'] as List).map((r) => List<int>.from(r)).toList(),
    isGiven: (j['isGiven'] as List).map((r) => List<bool>.from(r)).toList(),
    notes: (j['notes'] as List).map((r) => (r as List).map((c) => List<int>.from(c)).toList()).toList(),
    difficulty: j['difficulty'],
    seconds: j['seconds'],
    mistakes: j['mistakes'],
    hintCells: List<String>.from(j['hintCells'] ?? []),
  );
}

class GameStore extends ChangeNotifier {
  static const _key = 'sudoku_v2';

  String name = 'Player';
  String avatarColor = '#4F6EF7';
  String theme = 'light';
  int played = 0;
  int won = 0;
  Map<String, int?> bestTimes = {'easy': null, 'medium': null, 'hard': null, 'expert': null};
  List<ScoreEntry> scores = [];
  SavedGame? savedGame;

  // Daily Challenge & Streaks
  String? lastDailyPlayed; // Date string "yyyy-MM-dd"
  int currentStreak = 0;
  int longestStreak = 0;
  Map<String, int> dailyBestTimes = {}; // date -> time in seconds

  // Achievements
  Set<String> unlockedAchievements = {};
  int perfectGames = 0; // Games completed with 0 mistakes
  int noHintGames = 0; // Games completed without using hints
  int onlineWins = 0; // Online multiplayer wins
  Set<String> completedDifficulties = {}; // Difficulties completed at least once

  // Callback for newly unlocked achievements
  void Function(Achievement)? onAchievementUnlocked;

  bool get isDark => theme == 'dark';

  // Achievement helpers
  int get unlockedCount => unlockedAchievements.length;
  int get totalAchievements => Achievements.totalCount;
  double get achievementProgress => totalAchievements > 0 ? unlockedCount / totalAchievements : 0;

  bool hasAchievement(String id) => unlockedAchievements.contains(id);

  List<Achievement> get unlockedAchievementsList =>
      unlockedAchievements.map((id) => Achievements.getById(id)).whereType<Achievement>().toList();

  // Daily challenge helpers
  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get hasCompletedDailyToday => lastDailyPlayed == _todayString;

  int? get todayDailyTime => dailyBestTimes[_todayString];

  bool get canMaintainStreak {
    if (lastDailyPlayed == null) return true;
    final lastDate = DateTime.tryParse(lastDailyPlayed!);
    if (lastDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    return lastDay == yesterday || lastDay == today;
  }

  String get rankName {
    if (won >= 100) return 'Master';
    if (won >= 50) return 'Expert';
    if (won >= 20) return 'Advanced';
    if (won >= 10) return 'Intermediate';
    if (won >= 3) return 'Novice';
    return 'Beginner';
  }

  String get rankIcon {
    if (won >= 100) return '👑';
    if (won >= 50) return '🏆';
    if (won >= 20) return '⭐';
    if (won >= 10) return '🎯';
    if (won >= 3) return '🌱';
    return '🔰';
  }

  String get winRate => played > 0 ? '${(won / played * 100).round()}%' : '—';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        name = j['name'] ?? 'Player';
        avatarColor = j['avatarColor'] ?? '#4F6EF7';
        theme = j['theme'] ?? 'light';
        played = j['played'] ?? 0;
        won = j['won'] ?? 0;
        if (j['bestTimes'] != null) {
          bestTimes = Map<String, int?>.from(
            (j['bestTimes'] as Map).map((k, v) => MapEntry(k.toString(), v as int?)),
          );
        }
        if (j['scores'] != null) {
          scores = (j['scores'] as List).map((e) => ScoreEntry.fromJson(e)).toList();
        }
        if (j['savedGame'] != null) {
          savedGame = SavedGame.fromJson(j['savedGame']);
        }
        // Daily challenge data
        lastDailyPlayed = j['lastDailyPlayed'];
        currentStreak = j['currentStreak'] ?? 0;
        longestStreak = j['longestStreak'] ?? 0;
        if (j['dailyBestTimes'] != null) {
          dailyBestTimes = Map<String, int>.from(
            (j['dailyBestTimes'] as Map).map((k, v) => MapEntry(k.toString(), v as int)),
          );
        }
        // Check if streak is broken (missed a day)
        _checkStreakStatus();

        // Achievement data
        if (j['unlockedAchievements'] != null) {
          unlockedAchievements = Set<String>.from(j['unlockedAchievements'] as List);
        }
        perfectGames = j['perfectGames'] ?? 0;
        noHintGames = j['noHintGames'] ?? 0;
        onlineWins = j['onlineWins'] ?? 0;
        if (j['completedDifficulties'] != null) {
          completedDifficulties = Set<String>.from(j['completedDifficulties'] as List);
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  void _checkStreakStatus() {
    if (lastDailyPlayed == null) return;
    final lastDate = DateTime.tryParse(lastDailyPlayed!);
    if (lastDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final difference = today.difference(lastDay).inDays;

    // If more than 1 day has passed, streak is broken
    if (difference > 1) {
      currentStreak = 0;
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'name': name,
      'avatarColor': avatarColor,
      'theme': theme,
      'played': played,
      'won': won,
      'bestTimes': bestTimes,
      'scores': scores.map((s) => s.toJson()).toList(),
      'savedGame': savedGame?.toJson(),
      // Daily challenge data
      'lastDailyPlayed': lastDailyPlayed,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'dailyBestTimes': dailyBestTimes,
      // Achievement data
      'unlockedAchievements': unlockedAchievements.toList(),
      'perfectGames': perfectGames,
      'noHintGames': noHintGames,
      'onlineWins': onlineWins,
      'completedDifficulties': completedDifficulties.toList(),
    }));
  }

  void toggleTheme() {
    theme = isDark ? 'light' : 'dark';
    save();
    notifyListeners();
  }

  void updateProfile(String newName, String newColor) {
    name = newName.isNotEmpty ? newName : name;
    avatarColor = newColor;
    save();
    notifyListeners();
  }

  void recordWin(String difficulty, int time, int mistakes) {
    played++;
    won++;
    final bt = bestTimes[difficulty];
    if (bt == null || time < bt) bestTimes[difficulty] = time;
    scores.insert(0, ScoreEntry(
      diff: difficulty,
      time: time,
      mistakes: mistakes,
      date: _formatDate(DateTime.now()),
    ));
    if (scores.length > 20) scores.removeLast();
    savedGame = null;
    save();
    notifyListeners();
  }

  void recordLoss(String difficulty, int time, int mistakes) {
    played++;
    scores.insert(0, ScoreEntry(
      diff: difficulty,
      time: time,
      mistakes: mistakes,
      date: _formatDate(DateTime.now()),
    ));
    if (scores.length > 20) scores.removeLast();
    savedGame = null;
    save();
    notifyListeners();
  }

  void saveGame(SavedGame game) {
    savedGame = game;
    save();
  }

  void clearSavedGame() {
    savedGame = null;
    save();
    notifyListeners();
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  /// Record completion of daily challenge
  void recordDailyWin(int time, int mistakes) {
    final today = _todayString;

    // Don't record if already completed today
    if (lastDailyPlayed == today) return;

    // Update streak
    if (canMaintainStreak) {
      currentStreak++;
    } else {
      currentStreak = 1; // Start new streak
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Record time
    dailyBestTimes[today] = time;
    lastDailyPlayed = today;

    // Also count as a regular win
    played++;
    won++;

    // Add to scores with "daily" marker
    scores.insert(0, ScoreEntry(
      diff: 'daily',
      time: time,
      mistakes: mistakes,
      date: _formatDate(DateTime.now()),
    ));
    if (scores.length > 20) scores.removeLast();

    save();
    notifyListeners();
  }

  /// Record daily challenge loss (made 3 mistakes)
  void recordDailyLoss(int time, int mistakes) {
    // Daily loss doesn't break streak, but doesn't extend it either
    // Player can try again tomorrow
    played++;

    scores.insert(0, ScoreEntry(
      diff: 'daily',
      time: time,
      mistakes: mistakes,
      date: _formatDate(DateTime.now()),
    ));
    if (scores.length > 20) scores.removeLast();

    save();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACHIEVEMENT METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Unlock an achievement if not already unlocked
  void _unlockAchievement(Achievement achievement) {
    if (unlockedAchievements.contains(achievement.id)) return;
    unlockedAchievements.add(achievement.id);
    onAchievementUnlocked?.call(achievement);
  }

  /// Check and unlock achievements after a win
  void checkAchievements({
    required String difficulty,
    required int time,
    required int mistakes,
    required int hintsUsed,
    bool isChallenge = false,
    bool isOnline = false,
    bool isDaily = false,
    bool isOnlineWinner = false,
  }) {
    final newlyUnlocked = <Achievement>[];

    // Helper to track and unlock
    void tryUnlock(Achievement a) {
      if (!unlockedAchievements.contains(a.id)) {
        unlockedAchievements.add(a.id);
        newlyUnlocked.add(a);
      }
    }

    // ── Milestone achievements ──
    if (won >= 1) tryUnlock(Achievements.firstWin);
    if (won >= 10) tryUnlock(Achievements.wins10);
    if (won >= 25) tryUnlock(Achievements.wins25);
    if (won >= 50) tryUnlock(Achievements.wins50);
    if (won >= 100) tryUnlock(Achievements.wins100);
    if (won >= 250) tryUnlock(Achievements.wins250);

    // ── Perfection achievements ──
    if (mistakes == 0) {
      perfectGames++;
      tryUnlock(Achievements.perfectGame);
      if (perfectGames >= 5) tryUnlock(Achievements.perfect5);
      if (perfectGames >= 10) tryUnlock(Achievements.perfect10);
      if (perfectGames >= 25) tryUnlock(Achievements.perfect25);
    }

    // ── Comeback achievement ──
    if (mistakes == 2) {
      tryUnlock(Achievements.comeback);
    }

    // ── Speed achievements ──
    if (time < 300) tryUnlock(Achievements.speedDemon); // Under 5 min
    if (time < 180) tryUnlock(Achievements.lightningFast); // Under 3 min
    if (difficulty == 'easy' && time < 120) tryUnlock(Achievements.speedsterEasy);
    if (difficulty == 'medium' && time < 240) tryUnlock(Achievements.speedsterMedium);
    if (difficulty == 'hard' && time < 360) tryUnlock(Achievements.speedsterHard);
    if (difficulty == 'expert' && time < 600) tryUnlock(Achievements.speedsterExpert);

    // ── Difficulty achievements ──
    completedDifficulties.add(difficulty);
    if (difficulty == 'easy') tryUnlock(Achievements.completeEasy);
    if (difficulty == 'medium') tryUnlock(Achievements.completeMedium);
    if (difficulty == 'hard') tryUnlock(Achievements.completeHard);
    if (difficulty == 'expert') tryUnlock(Achievements.completeExpert);

    // Jack of All Trades - completed all difficulties
    if (completedDifficulties.containsAll(['easy', 'medium', 'hard', 'expert'])) {
      tryUnlock(Achievements.masterAllDifficulties);
    }

    // ── No hints achievements ──
    if (hintsUsed == 0) {
      noHintGames++;
      tryUnlock(Achievements.noHints);
      if (noHintGames >= 10) tryUnlock(Achievements.noHints10);
    }

    // ── Challenge achievement ──
    if (isChallenge) {
      tryUnlock(Achievements.challengeWin);
    }

    // ── Online achievements ──
    if (isOnline && isOnlineWinner) {
      onlineWins++;
      tryUnlock(Achievements.onlineWin);
      if (onlineWins >= 5) tryUnlock(Achievements.onlineWin5);
    }

    // ── Daily achievements ──
    if (isDaily) {
      tryUnlock(Achievements.dailyFirst);
    }

    // ── Streak achievements ──
    if (currentStreak >= 3) tryUnlock(Achievements.streak3);
    if (currentStreak >= 7) tryUnlock(Achievements.streak7);
    if (currentStreak >= 14) tryUnlock(Achievements.streak14);
    if (currentStreak >= 30) tryUnlock(Achievements.streak30);

    // ── Time-based achievements ──
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 0 && hour < 5) tryUnlock(Achievements.nightOwl);
    if (hour >= 5 && hour < 7) tryUnlock(Achievements.earlyBird);

    // Notify for each newly unlocked achievement
    for (final achievement in newlyUnlocked) {
      onAchievementUnlocked?.call(achievement);
    }

    save();
  }
}

