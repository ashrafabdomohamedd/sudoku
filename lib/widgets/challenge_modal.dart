import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../utils/challenge_utils.dart';

class ChallengeModal extends StatefulWidget {
  final AppColorScheme colors;
  final bool isDark;
  final void Function(String difficulty, int seed, String pin) onStartChallenge;

  const ChallengeModal({super.key, required this.colors, required this.isDark, required this.onStartChallenge});

  @override
  State<ChallengeModal> createState() => _ChallengeModalState();
}

class _ChallengeModalState extends State<ChallengeModal> {
  bool _isCreateTab = true;
  String _cDiff = 'easy';
  bool _generated = false;
  String _pin = '';
  int _seed = 0;
  final _pinController = TextEditingController();
  String _joinError = '';

  AppColorScheme get c => widget.colors;

  void _generate() {
    _seed = Random().nextInt(99999) + 1;
    _pin = ChallengeUtils.encodePin(_cDiff, _seed);
    setState(() => _generated = true);
  }

  void _join() {
    final data = ChallengeUtils.decodePin(_pinController.text);
    if (data == null) {
      setState(() => _joinError = 'Invalid PIN. Please check and try again.');
      return;
    }
    setState(() => _joinError = '');
    Navigator.pop(context);
    widget.onStartChallenge(data.difficulty, data.seed, _pinController.text.replaceAll(RegExp(r'\D'), ''));
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text('Challenge Mode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.text)),
            const SizedBox(height: 16),
            // Tabs
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  _tab('Create', _isCreateTab),
                  _tab('Join', !_isCreateTab),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_isCreateTab) _buildCreate() else _buildJoin(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border, width: 1.5), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.text)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCreateTab = label == 'Create'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)] : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? c.primary : c.textMuted)),
        ),
      ),
    );
  }

  Widget _buildCreate() {
    if (!_generated) {
      return Column(
        children: [
          Text('Choose difficulty for the challenge', style: TextStyle(fontSize: 13, color: c.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          _diffBar(),
          const SizedBox(height: 16),
          _gradBtn('Generate Challenge →', _generate),
        ],
      );
    }
    return Column(
      children: [
        Text('Share with your friend — they scan the QR or enter the PIN', style: TextStyle(fontSize: 13, color: c.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: QrImageView(data: 'sudoku://challenge?pin=$_pin', version: QrVersions.auto, size: 160),
        ),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Divider(color: c.border)), Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('or enter PIN', style: TextStyle(fontSize: 11, color: c.textMuted))), Expanded(child: Divider(color: c.border))]),
        const SizedBox(height: 6),
        Text(ChallengeUtils.formatPin(_pin), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c.primary, letterSpacing: 8)),
        const SizedBox(height: 4),
        Text('Difficulty: ${_cDiff[0].toUpperCase()}${_cDiff.substring(1)}', style: TextStyle(fontSize: 11, color: c.textMuted)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final txt = '⚔️ Sudoku Challenge!\nPIN: $_pin\nDifficulty: $_cDiff';
                  Clipboard.setData(ClipboardData(text: txt));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border, width: 1.5), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text('📋 Copy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.text)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _gradBtn('Start My Game →', () {
                widget.onStartChallenge(_cDiff, _seed, _pin);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJoin() {
    return Column(
      children: [
        Text('Enter the 6-digit PIN your friend shared', style: TextStyle(fontSize: 13, color: c.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c.text, letterSpacing: 8),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: c.surface2,
            hintText: '123456',
            hintStyle: TextStyle(fontSize: 18, color: c.textMuted, letterSpacing: 3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
          onSubmitted: (_) => _join(),
        ),
        if (_joinError.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_joinError, style: TextStyle(fontSize: 12, color: c.errColor)),
        ],
        const SizedBox(height: 10),
        _gradBtn('Join Challenge →', _join),
      ],
    );
  }

  Widget _diffBar() {
    const diffs = ['easy', 'medium', 'hard', 'expert'];
    return Row(
      children: diffs.map((d) {
        final active = d == _cDiff;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _cDiff = d),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? c.primary : c.surface,
                  border: Border.all(color: active ? c.primary : c.border, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(d[0].toUpperCase() + d.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : c.textMuted)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _gradBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]), borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}

