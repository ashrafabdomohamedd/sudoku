/// Challenge mode PIN encoding/decoding utility
class ChallengeUtils {
  static const _diffs = ['easy', 'medium', 'hard', 'expert'];

  /// Encode difficulty + seed into a 6-digit PIN
  static String encodePin(String difficulty, int seed) {
    final di = _diffs.indexOf(difficulty) + 1;
    return (di * 100000 + seed).toString().padLeft(6, '0');
  }

  /// Decode a PIN into difficulty + seed, or null if invalid
  static ({String difficulty, int seed})? decodePin(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\D'), '');
    final n = int.tryParse(cleaned);
    if (n == null || n < 100001 || n > 499999) return null;
    final di = n ~/ 100000;
    final seed = n % 100000;
    if (seed < 1 || di < 1 || di > 4) return null;
    return (difficulty: _diffs[di - 1], seed: seed);
  }

  /// Format PIN for display: "2  34 567" style
  static String formatPin(String pin) {
    if (pin.length < 6) return pin;
    // return pin;
    return '${pin.substring(0, 3)} ${pin.substring(3)}';
  }
}

