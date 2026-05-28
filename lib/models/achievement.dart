import 'package:flutter/material.dart';

/// Achievement rarity levels
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement categories
enum AchievementCategory {
  milestone,
  perfection,
  speed,
  streak,
  difficulty,
  special,
}

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.rarity = AchievementRarity.common,
    this.isSecret = false,
  });

  /// Get color based on rarity
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9CA3AF); // Gray
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF8B5CF6); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B); // Gold
    }
  }

  /// Get rarity display name
  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  /// Get category display name
  String get categoryName {
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

/// All achievements in the game
class Achievements {
  Achievements._();

  // ═══════════════════════════════════════════════════════════════════════════
  // MILESTONE ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const firstWin = Achievement(
    id: 'first_win',
    name: 'First Steps',
    description: 'Complete your first puzzle',
    icon: '🎯',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.common,
  );

  static const wins10 = Achievement(
    id: 'wins_10',
    name: 'Getting Started',
    description: 'Complete 10 puzzles',
    icon: '🌟',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.common,
  );

  static const wins25 = Achievement(
    id: 'wins_25',
    name: 'Puzzle Enthusiast',
    description: 'Complete 25 puzzles',
    icon: '⭐',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.rare,
  );

  static const wins50 = Achievement(
    id: 'wins_50',
    name: 'Dedicated Player',
    description: 'Complete 50 puzzles',
    icon: '🏅',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.rare,
  );

  static const wins100 = Achievement(
    id: 'wins_100',
    name: 'Century Club',
    description: 'Complete 100 puzzles',
    icon: '💯',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.epic,
  );

  static const wins250 = Achievement(
    id: 'wins_250',
    name: 'Sudoku Master',
    description: 'Complete 250 puzzles',
    icon: '👑',
    category: AchievementCategory.milestone,
    rarity: AchievementRarity.legendary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PERFECTION ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const perfectGame = Achievement(
    id: 'perfect_game',
    name: 'Flawless',
    description: 'Complete a puzzle with no mistakes',
    icon: '💎',
    category: AchievementCategory.perfection,
    rarity: AchievementRarity.common,
  );

  static const perfect5 = Achievement(
    id: 'perfect_5',
    name: 'Precision Player',
    description: 'Complete 5 puzzles with no mistakes',
    icon: '🎖️',
    category: AchievementCategory.perfection,
    rarity: AchievementRarity.rare,
  );

  static const perfect10 = Achievement(
    id: 'perfect_10',
    name: 'Perfectionist',
    description: 'Complete 10 puzzles with no mistakes',
    icon: '🏆',
    category: AchievementCategory.perfection,
    rarity: AchievementRarity.epic,
  );

  static const perfect25 = Achievement(
    id: 'perfect_25',
    name: 'Untouchable',
    description: 'Complete 25 puzzles with no mistakes',
    icon: '✨',
    category: AchievementCategory.perfection,
    rarity: AchievementRarity.legendary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPEED ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const speedDemon = Achievement(
    id: 'speed_demon',
    name: 'Speed Demon',
    description: 'Complete any puzzle in under 5 minutes',
    icon: '⚡',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.common,
  );

  static const lightningFast = Achievement(
    id: 'lightning_fast',
    name: 'Lightning Fast',
    description: 'Complete any puzzle in under 3 minutes',
    icon: '🚀',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.rare,
  );

  static const speedsterEasy = Achievement(
    id: 'speedster_easy',
    name: 'Easy Speedster',
    description: 'Complete an Easy puzzle in under 2 minutes',
    icon: '🏃',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.rare,
  );

  static const speedsterMedium = Achievement(
    id: 'speedster_medium',
    name: 'Medium Speedster',
    description: 'Complete a Medium puzzle in under 4 minutes',
    icon: '🏃‍♂️',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.epic,
  );

  static const speedsterHard = Achievement(
    id: 'speedster_hard',
    name: 'Hard Speedster',
    description: 'Complete a Hard puzzle in under 6 minutes',
    icon: '🏃‍♀️',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.epic,
  );

  static const speedsterExpert = Achievement(
    id: 'speedster_expert',
    name: 'Expert Speedster',
    description: 'Complete an Expert puzzle in under 10 minutes',
    icon: '💨',
    category: AchievementCategory.speed,
    rarity: AchievementRarity.legendary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAK ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const streak3 = Achievement(
    id: 'streak_3',
    name: 'Committed',
    description: 'Reach a 3-day streak',
    icon: '🔥',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.common,
  );

  static const streak7 = Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Reach a 7-day streak',
    icon: '📅',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.rare,
  );

  static const streak14 = Achievement(
    id: 'streak_14',
    name: 'Fortnight Fighter',
    description: 'Reach a 14-day streak',
    icon: '🗓️',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.epic,
  );

  static const streak30 = Achievement(
    id: 'streak_30',
    name: 'Monthly Master',
    description: 'Reach a 30-day streak',
    icon: '📆',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.legendary,
  );

  static const dailyFirst = Achievement(
    id: 'daily_first',
    name: 'Daily Challenger',
    description: 'Complete your first daily challenge',
    icon: '📅',
    category: AchievementCategory.streak,
    rarity: AchievementRarity.common,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DIFFICULTY ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const completeEasy = Achievement(
    id: 'complete_easy',
    name: 'Easy Does It',
    description: 'Complete an Easy puzzle',
    icon: '🌱',
    category: AchievementCategory.difficulty,
    rarity: AchievementRarity.common,
  );

  static const completeMedium = Achievement(
    id: 'complete_medium',
    name: 'Stepping Up',
    description: 'Complete a Medium puzzle',
    icon: '🌿',
    category: AchievementCategory.difficulty,
    rarity: AchievementRarity.common,
  );

  static const completeHard = Achievement(
    id: 'complete_hard',
    name: 'Challenge Accepted',
    description: 'Complete a Hard puzzle',
    icon: '🌳',
    category: AchievementCategory.difficulty,
    rarity: AchievementRarity.rare,
  );

  static const completeExpert = Achievement(
    id: 'complete_expert',
    name: 'Expert Mode',
    description: 'Complete an Expert puzzle',
    icon: '🏔️',
    category: AchievementCategory.difficulty,
    rarity: AchievementRarity.rare,
  );

  static const masterAllDifficulties = Achievement(
    id: 'master_all_difficulties',
    name: 'Jack of All Trades',
    description: 'Complete a puzzle in every difficulty',
    icon: '🎓',
    category: AchievementCategory.difficulty,
    rarity: AchievementRarity.epic,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const noHints = Achievement(
    id: 'no_hints',
    name: 'Self-Reliant',
    description: 'Complete a puzzle without using hints',
    icon: '🧠',
    category: AchievementCategory.special,
    rarity: AchievementRarity.common,
  );

  static const noHints10 = Achievement(
    id: 'no_hints_10',
    name: 'Brain Power',
    description: 'Complete 10 puzzles without using hints',
    icon: '🎓',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
  );

  static const challengeWin = Achievement(
    id: 'challenge_win',
    name: 'Challenger',
    description: 'Complete a challenge puzzle',
    icon: '⚔️',
    category: AchievementCategory.special,
    rarity: AchievementRarity.common,
  );

  static const onlineWin = Achievement(
    id: 'online_win',
    name: 'Online Victor',
    description: 'Win an online multiplayer match',
    icon: '🌐',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
  );

  static const onlineWin5 = Achievement(
    id: 'online_win_5',
    name: 'Online Champion',
    description: 'Win 5 online multiplayer matches',
    icon: '🏆',
    category: AchievementCategory.special,
    rarity: AchievementRarity.epic,
  );

  static const nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Complete a puzzle between midnight and 5 AM',
    icon: '🦉',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    isSecret: true,
  );

  static const earlyBird = Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Complete a puzzle between 5 AM and 7 AM',
    icon: '🐦',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    isSecret: true,
  );

  static const comeback = Achievement(
    id: 'comeback',
    name: 'Comeback Kid',
    description: 'Win with exactly 2 mistakes',
    icon: '💪',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    isSecret: true,
  );

  /// All achievements list
  static const List<Achievement> all = [
    // Milestones
    firstWin,
    wins10,
    wins25,
    wins50,
    wins100,
    wins250,
    // Perfection
    perfectGame,
    perfect5,
    perfect10,
    perfect25,
    // Speed
    speedDemon,
    lightningFast,
    speedsterEasy,
    speedsterMedium,
    speedsterHard,
    speedsterExpert,
    // Streaks
    streak3,
    streak7,
    streak14,
    streak30,
    dailyFirst,
    // Difficulty
    completeEasy,
    completeMedium,
    completeHard,
    completeExpert,
    masterAllDifficulties,
    // Special
    noHints,
    noHints10,
    challengeWin,
    onlineWin,
    onlineWin5,
    nightOwl,
    earlyBird,
    comeback,
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Total achievement count
  static int get totalCount => all.length;
}
