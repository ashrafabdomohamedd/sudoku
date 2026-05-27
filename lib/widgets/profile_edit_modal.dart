import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/game_store.dart';

class ProfileEditModal extends StatefulWidget {
  final GameStore store;
  final AppColorScheme colors;
  final VoidCallback onSave;

  const ProfileEditModal({super.key, required this.store, required this.colors, required this.onSave});

  @override
  State<ProfileEditModal> createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends State<ProfileEditModal> {
  late TextEditingController _nameCtrl;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.name);
    _selectedColor = widget.store.avatarColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.text))),
            const SizedBox(height: 18),
            Text('YOUR NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 5),
            TextField(
              controller: _nameCtrl,
              maxLength: 20,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.text),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: c.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.primary)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              ),
            ),
            const SizedBox(height: 16),
            Text('AVATAR COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: avatarColors.map((color) {
                final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                final active = hex == _selectedColor.toUpperCase();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: active ? c.text : Colors.transparent, width: 3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                widget.store.updateProfile(_nameCtrl.text.trim(), _selectedColor);
                widget.onSave();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F6EF7), Color(0xFFA855F7)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.border, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.text)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

