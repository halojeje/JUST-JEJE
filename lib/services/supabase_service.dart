import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'storage_service.dart';

class RemoteData {
  final List<TaskGroup> taskGroups;
  final List<PoolItem> poolItems;
  final String? username;
  final String? theme;

  RemoteData({
    required this.taskGroups,
    required this.poolItems,
    this.username,
    this.theme,
  });
}

class SyncResult {
  final bool success;
  final String message;

  SyncResult({required this.success, required this.message});
}

class SupabaseService {
  static SupabaseClient? _client;
  static String? _currentUrl;
  static String? _currentKey;
  static RealtimeChannel? _realtimeChannel;

  static SupabaseClient? getClient(SupabaseConfig config) {
    final url = config.url.trim();
    final key = config.publishableKey.trim();

    if (url.isEmpty || !url.startsWith("http")) {
      return null;
    }

    if (_client == null || _currentUrl != url || _currentKey != key) {
      try {
        _client = SupabaseClient(
          url,
          key.isNotEmpty ? key : StorageService.defaultPublishableKey,
        );
        _currentUrl = url;
        _currentKey = key;
      } catch (e) {
        return null;
      }
    }
    return _client;
  }

  static Future<SyncResult> testConnection(SupabaseConfig config) async {
    final client = getClient(config);
    if (client == null) {
      return SyncResult(
        success: false,
        message: "Supabase Project URL belum diatur. Masukkan URL project Anda terlebih dahulu.",
      );
    }

    try {
      await client.from("task_groups").select("id").limit(1);
      return SyncResult(
        success: true,
        message: "Berhasil terhubung ke Supabase Database!",
      );
    } on PostgrestException catch (err) {
      if (err.code == "42P01") {
        return SyncResult(
          success: false,
          message: "Koneksi berhasil, namun tabel belum dibuat! Silakan jalankan script supabase/schema.sql di Supabase SQL Editor.",
        );
      }
      return SyncResult(
        success: false,
        message: "Koneksi gagal: ${err.message}",
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: "Error koneksi: $e",
      );
    }
  }

  static Future<RemoteData?> fetchRemoteData(SupabaseConfig config) async {
    final client = getClient(config);
    if (client == null) return null;

    try {
      final results = await Future.wait([
        client.from("task_groups").select("*").order("created_at", ascending: true),
        client.from("tasks").select("*").order("created_at", ascending: true),
        client.from("pool_items").select("*").order("created_at", ascending: true),
        client.from("user_settings").select("*").eq("id", "default_user").maybeSingle(),
      ]);

      final rawGroups = results[0] as List<dynamic>? ?? [];
      final rawTasks = results[1] as List<dynamic>? ?? [];
      final rawPool = results[2] as List<dynamic>? ?? [];
      final settings = results[3] as Map<String, dynamic>?;

      // Group tasks by group_id
      final List<TaskGroup> taskGroups = rawGroups.map((g) {
        final gMap = g as Map<String, dynamic>;
        final groupId = gMap['id'] as String;
        final title = gMap['title'] as String? ?? 'Daftar Tugas';

        final matchingTasks = rawTasks.where((t) {
          final tMap = t as Map<String, dynamic>;
          return tMap['group_id'] == groupId;
        }).map((t) {
          final tMap = t as Map<String, dynamic>;
          return Task(
            id: tMap['id'] as String,
            text: tMap['text'] as String? ?? '',
            completed: tMap['completed'] as bool? ?? false,
            createdAt: (tMap['created_at'] is num)
                ? (tMap['created_at'] as num).toInt()
                : DateTime.now().millisecondsSinceEpoch,
            googleTaskId: tMap['google_task_id'] as String?,
          );
        }).toList();

        return TaskGroup(id: groupId, title: title, tasks: matchingTasks);
      }).toList();

      final List<PoolItem> poolItems = rawPool.map((p) {
        final pMap = p as Map<String, dynamic>;
        return PoolItem(
          id: pMap['id'] as String,
          text: pMap['text'] as String? ?? '',
          category: pMap['category'] as String? ?? 'Umum',
          createdAt: (pMap['created_at'] is num)
              ? (pMap['created_at'] as num).toInt()
              : DateTime.now().millisecondsSinceEpoch,
        );
      }).toList();

      return RemoteData(
        taskGroups: taskGroups,
        poolItems: poolItems,
        username: settings?['username'] as String?,
        theme: settings?['theme'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<SyncResult> pushAllToSupabase({
    required SupabaseConfig config,
    required List<TaskGroup> taskGroups,
    required List<PoolItem> poolItems,
    required String username,
    required String theme,
  }) async {
    final client = getClient(config);
    if (client == null) {
      return SyncResult(success: false, message: "Supabase client belum aktif.");
    }

    try {
      final currentGroupIds = taskGroups.map((g) => g.id).toList();

      // Clean up deleted groups from Supabase
      final remoteGroups = await client.from("task_groups").select("id");
      if (remoteGroups.isNotEmpty) {
        final groupsToDelete = remoteGroups
            .map((r) => r['id'] as String)
            .filter((id) => !currentGroupIds.contains(id))
            .toList();
        if (groupsToDelete.isNotEmpty) {
          await client.from("tasks").delete().filter("group_id", "in", groupsToDelete);
          await client.from("task_groups").delete().filter("id", "in", groupsToDelete);
        }
      }

      if (taskGroups.isNotEmpty) {
        final groupRows = taskGroups.map((g) => {
          'id': g.id,
          'title': g.title,
          'updated_at': DateTime.now().toIso8601String(),
        }).toList();

        await client.from("task_groups").upsert(groupRows, onConflict: "id");

        final List<Map<String, dynamic>> allTasks = [];
        for (var g in taskGroups) {
          for (var t in g.tasks) {
            allTasks.add({
              'id': t.id,
              'group_id': g.id,
              'text': t.text,
              'completed': t.completed,
              'created_at': t.createdAt,
              'google_task_id': t.googleTaskId,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        }

        final currentTaskIds = allTasks.map((t) => t['id'] as String).toList();
        final remoteTasks = await client.from("tasks").select("id");
        if (remoteTasks.isNotEmpty) {
          final tasksToDelete = remoteTasks
              .map((t) => t['id'] as String)
              .filter((id) => !currentTaskIds.contains(id))
              .toList();
          if (tasksToDelete.isNotEmpty) {
            await client.from("tasks").delete().filter("id", "in", tasksToDelete);
          }
        }

        if (allTasks.isNotEmpty) {
          await client.from("tasks").upsert(allTasks, onConflict: "id");
        }
      } else {
        await client.from("tasks").delete().neq("id", "none");
        await client.from("task_groups").delete().neq("id", "none");
      }

      // Sync Pool Items
      final currentPoolIds = poolItems.map((p) => p.id).toList();
      final remotePool = await client.from("pool_items").select("id");
      if (remotePool.isNotEmpty) {
        final poolToDelete = remotePool
            .map((p) => p['id'] as String)
            .filter((id) => !currentPoolIds.contains(id))
            .toList();
        if (poolToDelete.isNotEmpty) {
          await client.from("pool_items").delete().filter("id", "in", poolToDelete);
        }
      }

      if (poolItems.isNotEmpty) {
        final poolRows = poolItems.map((p) => {
          'id': p.id,
          'text': p.text,
          'category': p.category ?? 'Umum',
          'created_at': p.createdAt,
          'updated_at': DateTime.now().toIso8601String(),
        }).toList();

        await client.from("pool_items").upsert(poolRows, onConflict: "id");
      }

      // Sync User Settings
      await client.from("user_settings").upsert({
        'id': 'default_user',
        'username': username.isNotEmpty ? username : 'Username',
        'theme': theme.isNotEmpty ? theme : 'basic',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      return SyncResult(
        success: true,
        message: "Data berhasil disinkronkan ke Supabase Cloud!",
      );
    } catch (err) {
      return SyncResult(
        success: false,
        message: "Gagal upload ke Supabase: $err",
      );
    }
  }

  static Future<void> deleteGroupFromSupabase(SupabaseConfig config, String groupId) async {
    final client = getClient(config);
    if (client == null) return;
    try {
      await client.from("tasks").delete().eq("group_id", groupId);
      await client.from("task_groups").delete().eq("id", groupId);
    } catch (_) {}
  }

  static Future<void> deleteTaskFromSupabase(SupabaseConfig config, String taskId) async {
    final client = getClient(config);
    if (client == null) return;
    try {
      await client.from("tasks").delete().eq("id", taskId);
    } catch (_) {}
  }

  static Future<void> deletePoolItemFromSupabase(SupabaseConfig config, String poolItemId) async {
    final client = getClient(config);
    if (client == null) return;
    try {
      await client.from("pool_items").delete().eq("id", poolItemId);
    } catch (_) {}
  }

  static Future<void> updateUserSettingsInSupabase(
    SupabaseConfig config,
    String username,
    String theme,
  ) async {
    final client = getClient(config);
    if (client == null) return;
    try {
      await client.from("user_settings").upsert({
        'id': 'default_user',
        'username': username.isNotEmpty ? username : 'Username',
        'theme': theme.isNotEmpty ? theme : 'basic',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {}
  }

  static void Function() setupRealtimeSubscription(
    SupabaseConfig config,
    void Function() onRemoteChange,
  ) {
    final client = getClient(config);
    if (client == null) return () {};

    try {
      _realtimeChannel = client
          .channel("just_jeje_live_changes")
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: "public",
            table: "tasks",
            callback: (_) => onRemoteChange(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: "public",
            table: "task_groups",
            callback: (_) => onRemoteChange(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: "public",
            table: "pool_items",
            callback: (_) => onRemoteChange(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: "public",
            table: "user_settings",
            callback: (_) => onRemoteChange(),
          )
          .subscribe();

      return () {
        _realtimeChannel?.unsubscribe();
      };
    } catch (_) {
      return () {};
    }
  }
}

extension _IterableFilter<E> on Iterable<E> {
  Iterable<E> filter(bool Function(E element) test) => where(test);
}
