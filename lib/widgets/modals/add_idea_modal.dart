import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class AddIdeaModal extends StatefulWidget {
  final Function(String text, String? category) onAddIdea;
  final ThemeItem theme;

  const AddIdeaModal({
    super.key,
    required this.onAddIdea,
    required this.theme,
  });

  @override
  State<AddIdeaModal> createState() => _AddIdeaModalState();
}

class _AddIdeaModalState extends State<AddIdeaModal> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedCategory;

  static const List<String> categories = [
    "Produktif",
    "Anabul & Santai",
    "Belajar",
    "Olahraga",
    "Tugas Rumah",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context, rootNavigator: true).pop();
    widget.onAddIdea(text, _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: Color(0xFFEAB308)),
                    const SizedBox(width: 8),
                    Text(
                      "Tambah Ide ke Pool",
                      style: AppThemes.font(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: widget.theme.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Text Label & Input
            Text(
              "Ide Tugas / Aktivitas:",
              style: AppThemes.font(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              style: AppThemes.font(fontSize: 14, color: widget.theme.textPrimary),
              decoration: InputDecoration(
                hintText: "Contoh: Main sama anabul di cafe Kemang",
                hintStyle: AppThemes.font(fontSize: 13.5, color: widget.theme.textMuted),
                filled: true,
                fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.primary, width: 1.8),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 16),

            // Category Chips
            Text(
              "Kategori (Opsional):",
              style: AppThemes.font(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.theme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: AppThemes.font(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : widget.theme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: widget.theme.primary,
                  backgroundColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? cat : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: _submit,
                  child: Text(
                    "Simpan ke Pool",
                    style: AppThemes.font(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
