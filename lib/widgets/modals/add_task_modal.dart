import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_themes.dart';

class AddTaskModal extends StatefulWidget {
  final List<PoolItem> poolItems;
  final Function(String text) onAddTask;
  final Function(String title) onAddListGroup;
  final ThemeItem theme;

  const AddTaskModal({
    super.key,
    required this.poolItems,
    required this.onAddTask,
    required this.onAddListGroup,
    required this.theme,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  int _activeTab = 0; // 0: task, 1: list
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _listController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _handleTaskSubmit() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    widget.onAddTask(text);
    Navigator.pop(context);
  }

  void _handleListSubmit() {
    final title = _listController.text.trim();
    if (title.isEmpty) return;
    widget.onAddListGroup(title);
    Navigator.pop(context);
  }

  void _pickRandom() {
    if (widget.poolItems.isEmpty) return;
    final random = widget.poolItems[Random().nextInt(widget.poolItems.length)];
    setState(() {
      _taskController.text = random.text;
    });
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
            // Tabs Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _activeTab = 0),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 0 ? widget.theme.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          "Tambah Tugas",
                          style: AppThemes.font(
                            fontSize: 14.5,
                            fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.w500,
                            color: _activeTab == 0 ? widget.theme.primary : widget.theme.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _activeTab = 1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 1 ? widget.theme.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          "Buat List Baru",
                          style: AppThemes.font(
                            fontSize: 14.5,
                            fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.w500,
                            color: _activeTab == 1 ? widget.theme.primary : widget.theme.textMuted,
                          ),
                        ),
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
            const SizedBox(height: 20),

            if (_activeTab == 0) ...[
              // Task Input
              Text(
                "Nama Tugas:",
                style: AppThemes.font(fontSize: 13, fontWeight: FontWeight.w600, color: widget.theme.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taskController,
                autofocus: true,
                style: AppThemes.font(fontSize: 14, color: widget.theme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Ketik tugas baru...",
                  hintStyle: AppThemes.font(fontSize: 13.5, color: widget.theme.textMuted),
                  filled: true,
                  fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.theme.primary, width: 1.8),
                  ),
                ),
                onSubmitted: (_) => _handleTaskSubmit(),
              ),

              if (widget.poolItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.theme.primary,
                      side: BorderSide(color: widget.theme.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 14),
                    label: Text("Ambil ide acak dari pool", style: AppThemes.font(fontSize: 12)),
                    onPressed: _pickRandom,
                  ),
                ),
              ],

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text("Tambahkan Tugas", style: AppThemes.font(fontWeight: FontWeight.bold)),
                    onPressed: _handleTaskSubmit,
                  ),
                ],
              ),
            ] else ...[
              // List Input
              Text(
                "Judul List / Kategori Baru:",
                style: AppThemes.font(fontSize: 13, fontWeight: FontWeight.w600, color: widget.theme.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _listController,
                autofocus: true,
                style: AppThemes.font(fontSize: 14, color: widget.theme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Contoh: Pekerjaan Kantor, Belanja, Wishlist...",
                  hintStyle: AppThemes.font(fontSize: 13.5, color: widget.theme.textMuted),
                  filled: true,
                  fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.theme.primary, width: 1.8),
                  ),
                ),
                onSubmitted: (_) => _handleListSubmit(),
              ),

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text("Buat List", style: AppThemes.font(fontWeight: FontWeight.bold)),
                    onPressed: _handleListSubmit,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
