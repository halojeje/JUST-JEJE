import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';
import '../widgets/jeje_widget_card.dart';

class HomeWidgetService {
  static const String appWidgetProviderName = 'JejeWidgetProvider';
  static const String imageKey = 'jeje_card_image';

  /// Update the Android Home Screen Widget with the given [group] and [theme].
  /// If [group] is not provided, uses a default fallback task group.
  static Future<void> updateAppWidget({
    TaskGroup? group,
    ThemeItem? theme,
  }) async {
    // Only execute on Android platform and non-web
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    try {
      final targetGroup = group ??
          TaskGroup(
            id: 'default',
            title: 'JUST JEJE',
            tasks: [],
          );
      final targetTheme = theme ?? AppThemes.getThemeById('basic');

      // 1. Calculate summary text
      final completedCount = targetGroup.tasks.where((t) => t.completed).length;
      final totalCount = targetGroup.tasks.length;
      final summaryText = totalCount == 0
          ? '0 Tugas'
          : '$completedCount/$totalCount Selesai';

      // 2. Save structured strings for native fallback
      await HomeWidget.saveWidgetData<String>(
        'widget_group_title',
        targetGroup.title.isEmpty ? 'JUST JEJE' : targetGroup.title,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks_summary',
        summaryText,
      );

      // Save up to 3 individual task lines for native fallback
      for (int i = 0; i < 3; i++) {
        if (i < targetGroup.tasks.length) {
          final t = targetGroup.tasks[i];
          final prefix = t.completed ? '✓ ' : '• ';
          await HomeWidget.saveWidgetData<String>(
            'widget_task_${i + 1}',
            '$prefix${t.text}',
          );
        } else {
          await HomeWidget.saveWidgetData<String>('widget_task_${i + 1}', '');
        }
      }

      // 3. Render Flutter Widget into PNG file
      final cardWidget = JejeWidgetCard(
        group: targetGroup,
        theme: targetTheme,
      );

      await HomeWidget.renderFlutterWidget(
        cardWidget,
        key: imageKey,
        logicalSize: const Size(360, 220),
        pixelRatio: 3.0,
      );

      // 4. Request Android system to refresh the widget
      await HomeWidget.updateWidget(
        name: appWidgetProviderName,
        androidName: appWidgetProviderName,
      );
    } catch (e, stack) {
      debugPrint('HomeWidgetService.updateAppWidget error: $e');
      debugPrint('$stack');
    }
  }

  /// Convenience helper to update widget using list of task groups and theme
  static Future<void> syncFromGroups(
    List<TaskGroup> groups,
    ThemeItem theme, {
    String? preferredGroupId,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    TaskGroup? selectedGroup;
    if (preferredGroupId != null && groups.isNotEmpty) {
      selectedGroup = groups.firstWhere(
        (g) => g.id == preferredGroupId,
        orElse: () => groups.first,
      );
    } else if (groups.isNotEmpty) {
      // Pick first group that has tasks, or the first group
      selectedGroup = groups.firstWhere(
        (g) => g.tasks.isNotEmpty,
        orElse: () => groups.first,
      );
    }

    await updateAppWidget(group: selectedGroup, theme: theme);
  }
}
