import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/home_widget_service.dart';
import '../../theme/app_themes.dart';
import '../jeje_widget_card.dart';

class WidgetSettingsModal extends StatefulWidget {
  final List<TaskGroup> taskGroups;
  final ThemeItem theme;

  const WidgetSettingsModal({
    super.key,
    required this.taskGroups,
    required this.theme,
  });

  @override
  State<WidgetSettingsModal> createState() => _WidgetSettingsModalState();
}

class _WidgetSettingsModalState extends State<WidgetSettingsModal> {
  late String _selectedGroupId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskGroups.isNotEmpty) {
      _selectedGroupId = widget.taskGroups.first.id;
    } else {
      _selectedGroupId = 'default';
    }
  }

  TaskGroup get _currentGroup {
    if (widget.taskGroups.isEmpty) {
      return TaskGroup(
        id: 'default',
        title: 'JUST JEJE',
        tasks: [
          Task(
            id: 'demo-1',
            text: 'Contoh tugas di widget',
            completed: false,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
          Task(
            id: 'demo-2',
            text: 'Tugas yang sudah selesai',
            completed: true,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
      );
    }
    return widget.taskGroups.firstWhere(
      (g) => g.id == _selectedGroupId,
      orElse: () => widget.taskGroups.first,
    );
  }

  Future<void> _updateWidget() async {
    setState(() => _isUpdating = true);
    await HomeWidgetService.updateAppWidget(
      group: _currentGroup,
      theme: widget.theme,
    );
    if (!mounted) return;
    setState(() => _isUpdating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✓ Widget Android berhasil diperbarui!",
          style: AppThemes.font(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: widget.theme.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.theme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.widgets_outlined,
                      color: widget.theme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Widget Screen Android",
                          style: AppThemes.font(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: widget.theme.textPrimary,
                          ),
                        ),
                        Text(
                          "Tampilkan card to-do di layar utama HP",
                          style: AppThemes.font(
                            fontSize: 12,
                            color: widget.theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Group Selector (if multiple groups)
              if (widget.taskGroups.length > 1) ...[
                Text(
                  "Pilih Daftar yang Ditampilkan:",
                  style: AppThemes.font(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.theme.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGroupId,
                      isExpanded: true,
                      dropdownColor: widget.theme.panel,
                      items: widget.taskGroups.map((g) {
                        return DropdownMenuItem<String>(
                          value: g.id,
                          child: Text(
                            g.title,
                            style: AppThemes.font(
                              fontSize: 13.5,
                              color: widget.theme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedGroupId = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card Live Preview
              Text(
                "Preview Tampilan Widget:",
                style: AppThemes.font(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: JejeWidgetCard(
                    group: _currentGroup,
                    theme: widget.theme,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Update Button
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync, size: 18),
                  label: Text(
                    _isUpdating ? "Memperbarui..." : "Perbarui Widget Sekarang",
                    style: AppThemes.font(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  onPressed: _isUpdating ? null : _updateWidget,
                ),
              ),

              const SizedBox(height: 18),

              // Step-by-step instructions
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.theme.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.theme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 16,
                          color: widget.theme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Cara Memasang di Layar Utama HP:",
                            style: AppThemes.font(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "1. Tekan & tahan (long press) di area kosong Home Screen HP.\n"
                      "2. Pilih menu 'Widgets'.\n"
                      "3. Cari aplikasi 'JUST JEJE'.\n"
                      "4. Geser widget ke layar utama dan atur ukurannya.",
                      style: AppThemes.font(
                        fontSize: 11.5,
                        color: widget.theme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
