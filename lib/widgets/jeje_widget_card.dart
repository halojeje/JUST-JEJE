import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';

class JejeWidgetCard extends StatelessWidget {
  final TaskGroup group;
  final ThemeItem theme;

  const JejeWidgetCard({
    super.key,
    required this.group,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = group.tasks.where((t) => t.completed).length;
    final totalCount = group.tasks.length;
    final displayTasks = group.tasks.take(4).toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 360,
        height: 220,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.borderCard, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.isDark ? 0.3 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.title.isEmpty ? "JUST JEJE" : group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppThemes.font(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalCount == 0 ? "0 Tugas" : "$completedCount/$totalCount Selesai",
                    style: AppThemes.font(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Divider
            Container(
              height: 1,
              color: theme.borderLight,
            ),

            const SizedBox(height: 10),

            // Task List or Empty Placeholder
            Expanded(
              child: displayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 26,
                            color: theme.textMuted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Belum ada tugas di list ini",
                            style: AppThemes.font(
                              fontSize: 12.5,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: displayTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            children: [
                              Container(
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task.completed ? theme.primary : Colors.transparent,
                                  border: Border.all(
                                    color: task.completed ? theme.primary : theme.textMuted,
                                    width: 1.5,
                                  ),
                                ),
                                child: task.completed
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  task.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppThemes.font(
                                    fontSize: 12.5,
                                    fontWeight: task.completed ? FontWeight.normal : FontWeight.w500,
                                    color: task.completed ? theme.textMuted : theme.textPrimary,
                                    decoration: task.completed ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 6),

            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: theme.logo,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "JUST JEJE",
                      style: AppThemes.font(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    "Buka Aplikasi",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppThemes.font(
                      fontSize: 10,
                      color: theme.textMuted,
                    ),
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
