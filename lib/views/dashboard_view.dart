import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';
import '../widgets/task_card.dart';

class DashboardView extends StatelessWidget {
  final List<TaskGroup> taskGroups;
  final List<PoolItem> poolItems;
  final Function(String groupId) onDeleteGroup;
  final Function(String groupId, String newTitle) onUpdateGroupTitle;
  final Function(String groupId, String text) onAddTask;
  final Function(String groupId, String taskId) onToggleTask;
  final Function(String groupId, String taskId) onDeleteTask;
  final Function(String groupId, String taskId, String newText) onEditTask;
  final Function(String text) onSaveToPool;
  final VoidCallback onNavigateGenerate;
  final VoidCallback onOpenAddList;
  final VoidCallback onTriggerConfetti;
  final ThemeItem theme;

  const DashboardView({
    super.key,
    required this.taskGroups,
    required this.poolItems,
    required this.onDeleteGroup,
    required this.onUpdateGroupTitle,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
    required this.onSaveToPool,
    required this.onNavigateGenerate,
    required this.onOpenAddList,
    required this.onTriggerConfetti,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (taskGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Belum ada daftar to-do list.",
                style: AppThemes.font(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text("Buat List Baru", style: AppThemes.font(fontWeight: FontWeight.bold)),
                onPressed: onOpenAddList,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: taskGroups.length,
      itemBuilder: (context, index) {
        final group = taskGroups[index];
        return TaskCard(
          key: ValueKey(group.id),
          group: group,
          poolItems: poolItems,
          canDeleteGroup: true,
          onDeleteGroup: onDeleteGroup,
          onUpdateGroupTitle: onUpdateGroupTitle,
          onAddTask: onAddTask,
          onToggleTask: onToggleTask,
          onDeleteTask: onDeleteTask,
          onEditTask: onEditTask,
          onSaveToPool: onSaveToPool,
          onNavigateGenerate: onNavigateGenerate,
          onTriggerConfetti: onTriggerConfetti,
          theme: theme,
        );
      },
    );
  }
}
