import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool get isDark => theme == 'dark';

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
      } catch (_) {}
    }
    notifyListeners();
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
}

