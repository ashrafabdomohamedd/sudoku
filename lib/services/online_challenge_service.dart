import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/online_room.dart';

/// Service for managing online multiplayer challenge rooms via Firebase Realtime Database
class OnlineChallengeService {
  static final OnlineChallengeService _instance = OnlineChallengeService._internal();
  factory OnlineChallengeService() => _instance;
  OnlineChallengeService._internal();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String? _currentRoomPin;
  String? _currentUid;
  StreamSubscription<DatabaseEvent>? _roomSubscription;
  Timer? _presenceTimer;

  final _roomStateController = StreamController<OnlineRoom?>.broadcast();
  Stream<OnlineRoom?> get roomStateStream => _roomStateController.stream;

  String? get currentRoomPin => _currentRoomPin;
  String? get currentUid => _currentUid;
  bool get isInRoom => _currentRoomPin != null;

  /// Get current room state immediately (for initial load)
  Future<OnlineRoom?> getCurrentRoom() async {
    if (_currentRoomPin == null) return null;

    try {
      final snapshot = await _db.child('rooms/$_currentRoomPin').get();
      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      return OnlineRoom.fromMap(_currentRoomPin!, data);
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique 6-digit PIN for the room
  String _generatePin() {
    final random = Random();
    // Generate PIN between 100000 and 999999
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Generate a unique user ID for this session
  String _generateUid() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new online challenge room
  Future<String?> createRoom(String difficulty, int seed, String playerName) async {
    // Clean up any existing room first
    await leaveRoom();

    // Try up to 5 times to generate a unique PIN
    for (int attempt = 0; attempt < 5; attempt++) {
      final pin = _generatePin();
      final roomRef = _db.child('rooms/$pin');

      // Check if room already exists
      final snapshot = await roomRef.get();
      if (snapshot.exists) continue;

      _currentUid = _generateUid();
      _currentRoomPin = pin;

      final now = DateTime.now().millisecondsSinceEpoch;
      final roomData = {
        'difficulty': difficulty,
        'seed': seed,
        'status': 'waiting',
        'createdAt': now,
        'startedAt': null,
        'winner': null,
        'players': {
          _currentUid!: {
            'name': playerName,
            'progress': 0,
            'mistakes': 0,
            'status': 'waiting',
            'finishTime': null,
            'lastSeen': now,
          }
        }
      };

      try {
        await roomRef.set(roomData);
        _startListening();
        _startPresenceUpdates();
        return pin;
      } catch (e) {
        _currentRoomPin = null;
        _currentUid = null;
        continue;
      }
    }
    return null;
  }

  /// Join an existing room by PIN
  Future<({bool success, String? error, String? difficulty, int? seed})> joinRoom(String pin, String playerName) async {
    // Clean up any existing room first
    await leaveRoom();

    final roomRef = _db.child('rooms/$pin');
    final snapshot = await roomRef.get();

    if (!snapshot.exists) {
      return (success: false, error: 'Room not found. Check the PIN and try again.', difficulty: null, seed: null);
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    final room = OnlineRoom.fromMap(pin, data);

    if (room.isFull) {
      return (success: false, error: 'Room is full. Only 2 players allowed.', difficulty: null, seed: null);
    }

    if (!room.isWaiting) {
      return (success: false, error: 'Game already started in this room.', difficulty: null, seed: null);
    }

    // Check if room is expired (older than 1 hour)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - room.createdAt > 3600000) {
      // Clean up expired room
      await roomRef.remove();
      return (success: false, error: 'This challenge has expired. Ask for a new PIN.', difficulty: null, seed: null);
    }

    _currentUid = _generateUid();
    _currentRoomPin = pin;

    final playerData = {
      'name': playerName,
      'progress': 0,
      'mistakes': 0,
      'status': 'waiting',
      'finishTime': null,
      'lastSeen': now,
    };

    try {
      await roomRef.child('players/$_currentUid').set(playerData);
      _startListening();
      _startPresenceUpdates();
      return (success: true, error: null, difficulty: room.difficulty, seed: room.seed);
    } catch (e) {
      _currentRoomPin = null;
      _currentUid = null;
      return (success: false, error: 'Failed to join room. Please try again.', difficulty: null, seed: null);
    }
  }

  /// Leave the current room
  Future<void> leaveRoom() async {
    _stopListening();
    _stopPresenceUpdates();

    if (_currentRoomPin != null && _currentUid != null) {
      final roomRef = _db.child('rooms/$_currentRoomPin');
      final pin = _currentRoomPin!;

      // Mark player as disconnected
      try {
        await roomRef.child('players/$_currentUid/status').set('disconnected');
      } catch (_) {}

      // Check room state and clean up if needed
      try {
        final snapshot = await roomRef.get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          final room = OnlineRoom.fromMap(pin, data);

          // If room is waiting and we're the only player, delete the room
          if (room.isWaiting && room.players.length == 1) {
            await roomRef.remove();
          } else {
            // Check if all players are disconnected or finished - close the room
            bool allDone = true;
            for (final player in room.players.values) {
              if (player.status != 'disconnected' && player.status != 'finished') {
                allDone = false;
                break;
              }
            }
            if (allDone) {
              await roomRef.update({'status': 'closed'});
            }
          }
        }
      } catch (_) {}
    }

    _currentRoomPin = null;
    _currentUid = null;
    _roomStateController.add(null);
  }

  /// Mark both players as ready and start the game
  Future<void> startGame() async {
    if (_currentRoomPin == null) return;

    final roomRef = _db.child('rooms/$_currentRoomPin');
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // Get current players
      final snapshot = await roomRef.child('players').get();
      if (!snapshot.exists) return;

      final players = snapshot.value as Map<dynamic, dynamic>;
      final updates = <String, dynamic>{
        'status': 'playing',
        'startedAt': now,
      };

      // Set all players to 'playing'
      for (final uid in players.keys) {
        updates['players/$uid/status'] = 'playing';
      }

      await roomRef.update(updates);
    } catch (_) {}
  }

  /// Update player's progress (cells filled and mistakes)
  Future<void> updateProgress(int filledCells, int mistakes) async {
    if (_currentRoomPin == null || _currentUid == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      final updates = {
        'progress': filledCells,
        'mistakes': mistakes,
        'lastSeen': now,
      };
      await _db.child('rooms/$_currentRoomPin/players/$_currentUid').update(updates);
    } catch (_) {
      // Silently fail - will retry on next update
    }
  }

  /// Mark player as finished with their completion time
  Future<void> markFinished(int totalSeconds) async {
    if (_currentRoomPin == null || _currentUid == null) return;

    final roomRef = _db.child('rooms/$_currentRoomPin');
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // Update this player's status
      await roomRef.child('players/$_currentUid').update({
        'status': 'finished',
        'finishTime': totalSeconds,
        'progress': 81,
        'lastSeen': now,
      });

      // Check if both players finished to determine winner
      final snapshot = await roomRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      final room = OnlineRoom.fromMap(_currentRoomPin!, data);

      // Check if all players have finished
      bool allFinished = true;
      String? winner;
      int? bestTime;

      for (final entry in room.players.entries) {
        if (!entry.value.isFinished && !entry.value.isDisconnected) {
          allFinished = false;
          break;
        }
        if (entry.value.isFinished) {
          final time = entry.value.finishTime;
          if (time != null && (bestTime == null || time < bestTime)) {
            bestTime = time;
            winner = entry.key;
          }
        }
      }

      if (allFinished && winner != null) {
        await roomRef.update({
          'status': 'finished',
          'winner': winner,
        });
      }
    } catch (_) {}
  }

  /// Mark player as lost (too many mistakes)
  Future<void> markLost() async {
    if (_currentRoomPin == null || _currentUid == null) return;

    final roomRef = _db.child('rooms/$_currentRoomPin');
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await roomRef.child('players/$_currentUid').update({
        'status': 'finished',
        'finishTime': null, // null indicates they lost
        'lastSeen': now,
      });

      // Check if opponent won by default
      final snapshot = await roomRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      final room = OnlineRoom.fromMap(_currentRoomPin!, data);
      final opponentUid = room.getOpponentUid(_currentUid!);

      if (opponentUid != null) {
        final opponent = room.players[opponentUid];
        if (opponent != null && (opponent.isFinished || opponent.isDisconnected)) {
          // Determine winner
          String? winner;
          if (opponent.isFinished && opponent.finishTime != null) {
            winner = opponentUid;
          }
          await roomRef.update({
            'status': 'finished',
            'winner': winner,
          });
        }
      }
    } catch (_) {}
  }

  /// Update presence timestamp
  void _updatePresence() async {
    if (_currentRoomPin == null || _currentUid == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      await _db.child('rooms/$_currentRoomPin/players/$_currentUid/lastSeen').set(now);
    } catch (_) {}
  }

  void _startPresenceUpdates() {
    _presenceTimer?.cancel();
    // Update presence every 3 seconds for better responsiveness
    _presenceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _updatePresence();
    });
  }

  void _stopPresenceUpdates() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  void _startListening() {
    _stopListening();

    if (_currentRoomPin == null) return;

    _roomSubscription = _db.child('rooms/$_currentRoomPin').onValue.listen((event) {
      if (!event.snapshot.exists) {
        _roomStateController.add(null);
        return;
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final room = OnlineRoom.fromMap(_currentRoomPin!, data);

      // Emit the room state - let the UI handle display
      // Don't auto-mark players as disconnected here to avoid race conditions
      _roomStateController.add(room);
    });
  }

  /// Check if a player appears to be disconnected (for UI display only)
  bool isPlayerInactive(PlayerState player) {
    if (player.status == 'disconnected' || player.status == 'finished') {
      return false; // Already has a final status
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - player.lastSeen > 30000; // 30 seconds of inactivity
  }

  void _stopListening() {
    _roomSubscription?.cancel();
    _roomSubscription = null;
  }

  /// Clean up resources
  void dispose() {
    _stopListening();
    _stopPresenceUpdates();
    _roomStateController.close();
  }
}
