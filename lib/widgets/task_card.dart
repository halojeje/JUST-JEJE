import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';

class TaskCard extends StatefulWidget {
  final TaskGroup group;
  final List<PoolItem> poolItems;
  final bool canDeleteGroup;
  final Function(String groupId) onDeleteGroup;
  final Function(String groupId, String newTitle) onUpdateGroupTitle;
  final Function(String groupId, String text) onAddTask;
  final Function(String groupId, String taskId) onToggleTask;
  final Function(String groupId, String taskId) onDeleteTask;
  final Function(String groupId, String taskId, String newText) onEditTask;
  final Function(String text) onSaveToPool;
  final VoidCallback onNavigateGenerate;
  final VoidCallback onTriggerConfetti;
  final ThemeItem theme;

  const TaskCard({
    super.key,
    required this.group,
    required this.poolItems,
    this.canDeleteGroup = false,
    required this.onDeleteGroup,
    required this.onUpdateGroupTitle,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
    required this.onSaveToPool,
    required this.onNavigateGenerate,
    required this.onTriggerConfetti,
    required this.theme,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isEditingTitle = false;
  late TextEditingController _titleController;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  String? _editingTaskId;
  final TextEditingController _editTaskController = TextEditingController();

  bool _isGenerating = false;
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.title);
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.title != widget.group.title && !_isEditingTitle) {
      _titleController.text = widget.group.title;
    }
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _titleController.dispose();
    _inputController.dispose();
    _editTaskController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _submitTitle() {
    final text = _titleController.text.trim();
    if (text.isNotEmpty) {
      widget.onUpdateGroupTitle(widget.group.id, text);
    } else {
      _titleController.text = widget.group.title;
    }
    setState(() {
      _isEditingTitle = false;
    });
  }

  void _handleManualAdd() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    widget.onAddTask(widget.group.id, text);
    _inputController.clear();
  }

  void _handleGenerateClick() {
    final typedText = _inputController.text.trim();
    if (typedText.isNotEmpty) {
      widget.onAddTask(widget.group.id, typedText);
      _inputController.clear();
      return;
    }

    if (widget.poolItems.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: widget.theme.panel,
          title: Text(
            "Bank Idea Kosong",
            style: AppThemes.font(fontWeight: FontWeight.bold, color: widget.theme.textPrimary),
          ),
          content: Text(
            "Bank ide di page Generate masih kosong!\n\nMau buka page Generate untuk menambah ide tugas sekarang?",
            style: AppThemes.font(color: widget.theme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Nanti", style: AppThemes.font(color: widget.theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onNavigateGenerate();
              },
              child: Text("Buka Bank Idea", style: AppThemes.font(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    int count = 0;
    final random = Random();
    _shuffleTimer?.cancel();
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 65), (timer) {
      count++;
      final preview = widget.poolItems[random.nextInt(widget.poolItems.length)];
      _inputController.text = preview.text;

      if (count > 6) {
        timer.cancel();
        final finalItem = widget.poolItems[random.nextInt(widget.poolItems.length)];
        _inputController.clear();
        widget.onAddTask(widget.group.id, finalItem.text);
        widget.onTriggerConfetti();

        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  void _handleToggleTask(Task task) {
    widget.onToggleTask(widget.group.id, task.id);
    if (!task.completed) {
      widget.onTriggerConfetti();
    }
  }

  void _startEditTask(Task task) {
    setState(() {
      _editingTaskId = task.id;
      _editTaskController.text = task.text;
    });
  }

  void _saveEditTask(String taskId) {
    final text = _editTaskController.text.trim();
    if (text.isNotEmpty) {
      widget.onEditTask(widget.group.id, taskId, text);
    }
    setState(() {
      _editingTaskId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Title & Edit / Delete Card
          Row(
            children: [
              Expanded(
                child: _isEditingTitle
                    ? TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        autofocus: true,
                        style: AppThemes.font(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: widget.theme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.theme.primary),
                          ),
                        ),
                        onSubmitted: (_) => _submitTitle(),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            _isEditingTitle = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.group.title,
                                style: AppThemes.font(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: widget.theme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: widget.theme.textMuted,
                            ),
                          ],
                        ),
                      ),
              ),
              if (_isEditingTitle)
                IconButton(
                  icon: const Icon(Icons.check, size: 20),
                  color: widget.theme.primary,
                  onPressed: _submitTitle,
                )
              else if (widget.canDeleteGroup)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red.shade400,
                  tooltip: "Hapus daftar ini",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: widget.theme.panel,
                        title: Text("Hapus Daftar?", style: AppThemes.font(fontWeight: FontWeight.bold, color: widget.theme.textPrimary)),
                        content: Text(
                          "Yakin ingin menghapus list \"${widget.group.title}\" beserta semua tugas di dalamnya?",
                          style: AppThemes.font(color: widget.theme.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onDeleteGroup(widget.group.id);
                            },
                            child: Text("Hapus", style: AppThemes.font(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Tasks List
          if (widget.group.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  "Belum ada tugas. Tulis manual di bawah atau klik Generate!",
                  textAlign: TextAlign.center,
                  style: AppThemes.font(
                    fontSize: 13,
                    color: widget.theme.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            )
          else
            ...widget.group.tasks.map((task) {
              final isEditing = _editingTaskId == task.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: task.completed
                      ? (widget.theme.isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB))
                      : (widget.theme.isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: task.completed
                        ? widget.theme.borderLight.withValues(alpha: 0.5)
                        : widget.theme.borderLight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Custom Square Checkbox
                    GestureDetector(
                      onTap: () => _handleToggleTask(task),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: task.completed ? widget.theme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.completed ? widget.theme.primary : widget.theme.textMuted,
                            width: 1.8,
                          ),
                        ),
                        child: task.completed
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text / Inline Edit
                    Expanded(
                      child: isEditing
                          ? Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _editTaskController,
                                    autofocus: true,
                                    style: AppThemes.font(
                                      fontSize: 13.5,
                                      color: widget.theme.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onSubmitted: (_) => _saveEditTask(task.id),
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
                                  onPressed: () => _saveEditTask(task.id),
                                  child: Text("Simpan", style: AppThemes.font(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () => _handleToggleTask(task),
                              child: Text(
                                task.text,
                                style: AppThemes.font(
                                  fontSize: 13.8,
                                  fontWeight: FontWeight.w500,
                                  color: task.completed
                                      ? widget.theme.textMuted
                                      : widget.theme.textPrimary,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: widget.theme.textMuted,
                                ),
                              ),
                            ),
                    ),

                    // 3-dots Menu
                    if (!isEditing)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 19, color: widget.theme.textMuted),
                        padding: EdgeInsets.zero,
                        color: widget.theme.panel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: widget.theme.borderCard),
                        ),
                        onSelected: (action) {
                          if (action == 'edit') {
                            _startEditTask(task);
                          } else if (action == 'save_pool') {
                            widget.onSaveToPool(task.text);
                          } else if (action == 'delete') {
                            widget.onDeleteTask(widget.group.id, task.id);
                          }
                        },
                        itemBuilder: (ctx) => [
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
                            value: 'save_pool',
                            child: Row(
                              children: [
                                const Icon(Icons.bookmark_add_outlined, size: 16),
                                const SizedBox(width: 10),
                                Text("Simpan ke Pool Generate", style: AppThemes.font(fontSize: 13, color: widget.theme.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                const SizedBox(width: 10),
                                Text("Hapus", style: AppThemes.font(fontSize: 13, color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),

          // Bottom Input Row: TextField + Generate Button
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
                    controller: _inputController,
                    enabled: !_isGenerating,
                    style: AppThemes.font(
                      fontSize: 13.5,
                      color: widget.theme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tulis atau pilih randomize",
                      hintStyle: AppThemes.font(
                        fontSize: 13.5,
                        color: widget.theme.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleManualAdd(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isGenerating ? null : _handleGenerateClick,
                  child: Text(
                    _isGenerating ? "Picking..." : "Generate",
                    style: AppThemes.font(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
