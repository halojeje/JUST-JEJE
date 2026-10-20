import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';

class GenerateView extends StatefulWidget {
  final List<PoolItem> poolItems;
  final Function(String id) onDeletePoolItem;
  final Function(String id, String newText) onEditPoolItem;
  final Function(String text) onSendToDashboard;
  final VoidCallback onOpenAddIdea;
  final VoidCallback onRestoreDefaults;
  final Function(String text, String? category) onAddIdea;
  final ThemeItem theme;

  const GenerateView({
    super.key,
    required this.poolItems,
    required this.onDeletePoolItem,
    required this.onEditPoolItem,
    required this.onSendToDashboard,
    required this.onOpenAddIdea,
    required this.onRestoreDefaults,
    required this.onAddIdea,
    required this.theme,
  });

  @override
  State<GenerateView> createState() => _GenerateViewState();
}

class _GenerateViewState extends State<GenerateView> {
  final TextEditingController _quickAddController = TextEditingController();
  String? _editingId;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _quickAddController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _handleQuickAdd() {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;
    widget.onAddIdea(text, null);
    _quickAddController.clear();
  }

  void _startEdit(PoolItem item) {
    setState(() {
      _editingId = item.id;
      _editController.text = item.text;
    });
  }

  void _saveEdit(String id) {
    final text = _editController.text.trim();
    if (text.isNotEmpty) {
      widget.onEditPoolItem(id, text);
    }
    setState(() {
      _editingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.theme.borderCard, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.theme.isDark ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Title, Count badge & + Tambah Ide button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: widget.theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Bank Idea",
                      style: AppThemes.font(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.theme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${widget.poolItems.length} ide",
                        style: AppThemes.font(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.theme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: widget.onOpenAddIdea,
                  child: Text(
                    "+ Tambah Ide",
                    style: AppThemes.font(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Informational Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.theme.isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.theme.isDark ? widget.theme.borderLight : const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, size: 16, color: widget.theme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ide di bawah ini akan diacak saat kamu klik Generate di Dashboard.",
                      style: AppThemes.font(
                        fontSize: 12,
                        color: widget.theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pool List
            if (widget.poolItems.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text("🎲", style: TextStyle(fontSize: 38)),
                    const SizedBox(height: 12),
                    Text(
                      "Pool Ide Masih Kosong",
                      style: AppThemes.font(fontSize: 15, fontWeight: FontWeight.bold, color: widget.theme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tambahkan ide aktivitas atau tugas agar sistem bisa mengacaknya untuk to-do harianmu.",
                      textAlign: TextAlign.center,
                      style: AppThemes.font(fontSize: 12.5, color: widget.theme.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.theme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: widget.onOpenAddIdea,
                          child: Text("+ Tambah Ide Pertama", style: AppThemes.font(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.theme.textSecondary,
                            side: BorderSide(color: widget.theme.borderLight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: widget.onRestoreDefaults,
                          child: Text("Muat Ide Contoh", style: AppThemes.font(fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              ...widget.poolItems.map((item) {
                final isEditing = _editingId == item.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.theme.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.theme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: isEditing
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _editController,
                                      autofocus: true,
                                      style: AppThemes.font(fontSize: 13.5, color: widget.theme.textPrimary),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      onSubmitted: (_) => _saveEdit(item.id),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.theme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () => _saveEdit(item.id),
                                    child: Text("Simpan", style: AppThemes.font(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.text,
                                    style: AppThemes.font(
                                      fontSize: 13.8,
                                      fontWeight: FontWeight.w500,
                                      color: widget.theme.textPrimary,
                                    ),
                                  ),
                                  if (item.category != null && item.category!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.category!,
                                      style: AppThemes.font(
                                        fontSize: 11,
                                        color: widget.theme.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      if (!isEditing)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 20, color: widget.theme.textMuted),
                          padding: EdgeInsets.zero,
                          color: widget.theme.panel,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: widget.theme.borderCard),
                          ),
                          onSelected: (action) {
                            if (action == 'send') {
                              widget.onSendToDashboard(item.text);
                            } else if (action == 'edit') {
                              _startEdit(item);
                            } else if (action == 'delete') {
                              widget.onDeletePoolItem(item.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'send',
                              child: Row(
                                children: [
                                  const Icon(Icons.send_rounded, size: 16),
                                  const SizedBox(width: 10),
                                  Text("Kirim ke To-Do Hari Ini", style: AppThemes.font(fontSize: 13, color: widget.theme.textPrimary)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 16),
                                  const SizedBox(width: 10),
                                  Text("Edit Teks", style: AppThemes.font(fontSize: 13, color: widget.theme.textPrimary)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Text("Hapus dari Pool", style: AppThemes.font(fontSize: 13, color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 14),

            // Quick Add Row
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.theme.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickAddController,
                      style: AppThemes.font(fontSize: 13.5, color: widget.theme.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Ketik ide baru & tekan Enter...",
                        hintStyle: AppThemes.font(fontSize: 13.5, color: widget.theme.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleQuickAdd(),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _handleQuickAdd,
                    child: Text(
                      "+ Tambah",
                      style: AppThemes.font(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
