import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/online_room.dart';

/// Widget showing opponent's progress during online challenge
class OpponentProgressBar extends StatelessWidget {
  final PlayerState opponent;
  final AppColorScheme colors;

  const OpponentProgressBar({
    super.key,
    required this.opponent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = opponent.progressPercent;
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Opponent avatar
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  opponent.name.isNotEmpty ? opponent.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponent.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _statusDot(statusColor),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        if (opponent.isPlaying) ...[
                          Text(
                            ' • ${opponent.mistakes} mistake${opponent.mistakes == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                        if (opponent.isFinished && opponent.finishTime != null) ...[
                          Text(
                            ' • ${_formatTime(opponent.finishTime!)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Progress percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progressPercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 6,
              backgroundColor: colors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 4),
          // Cells filled
          Text(
            '${opponent.progress}/81 cells',
            style: TextStyle(
              fontSize: 9,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (opponent.isFinished) {
      return opponent.finishTime != null
          ? const Color(0xFF10B981) // Green for finished
          : const Color(0xFFEF4444); // Red for lost
    }
    if (opponent.isDisconnected) return const Color(0xFF6B7280); // Gray
    if (opponent.isPlaying) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFFF59E0B); // Yellow for waiting
  }

  String _getStatusText() {
    if (opponent.isFinished) {
      return opponent.finishTime != null ? 'Finished' : 'Game Over';
    }
    if (opponent.isDisconnected) return 'Disconnected';
    if (opponent.isPlaying) return 'Playing';
    return 'Waiting';
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Compact waiting indicator for online challenge
class OnlineWaitingIndicator extends StatelessWidget {
  final String pin;
  final int playerCount;
  final AppColorScheme colors;
  final VoidCallback onCancel;

  const OnlineWaitingIndicator({
    super.key,
    required this.pin,
    required this.playerCount,
    required this.colors,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waiting for opponent...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                Text(
                  'PIN: ${_formatPin(pin)} • $playerCount/2 players',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.errColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.errColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPin(String pin) {
    if (pin.length != 6) return pin;
    return '${pin.substring(0, 3)} ${pin.substring(3)}';
  }
}
