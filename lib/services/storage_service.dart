import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _keyTaskGroups = 'just_jeje_task_groups';
  static const String _keyGeneratePool = 'just_jeje_generate_pool';
  static const String _keyGoogleConfig = 'just_jeje_google_config';
  static const String _keySupabaseConfig = 'just_jeje_supabase_config';
  static const String _keyUsername = 'just_jeje_username';
  static const String _keyTheme = 'just_jeje_theme';
  static const String _keyIsLoggedIn = 'just_jeje_is_logged_in';
  static const String _keyUserEmail = 'just_jeje_user_email';
  static const String _keyUserPicture = 'just_jeje_user_picture';

  static const String defaultSupabaseUrl = "https://vfkxwjjcdbbhtnxwaxqt.supabase.co";
  static const String defaultPublishableKey = "sb_publishable_OzVTIo6VWy75OToG4rOZfw_PQZZxP7Z";
  static const String defaultGoogleClientId = "682229986383-l3g3p8pck2461v835r42lvd9h4q85e1p.apps.googleusercontent.com";

  static List<TaskGroup> getDefaultTaskGroups() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      TaskGroup(
        id: 'group-today',
        title: 'Yang Harus Dikerjakan Hari ini!!',
        tasks: [
          Task(
            id: 'task-1',
            text: 'Cari tempat printing bagus di dekat rumah sa...',
            completed: false,
            createdAt: now - 3600000,
          ),
        ],
      ),
    ];
  }

  static List<PoolItem> getDefaultPoolItems() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      PoolItem(
        id: 'pool-1',
        text: 'Tulis summary buat Lomba',
        category: 'Produktif',
        createdAt: now - 7200000,
      ),
      PoolItem(
        id: 'pool-2',
        text: 'Main sama anabul di cafe Kemang',
        category: 'Anabul & Santai',
        createdAt: now - 3600000,
      ),
    ];
  }

  static GoogleSyncConfig getDefaultGoogleConfig() {
    return GoogleSyncConfig(
      clientId: defaultGoogleClientId,
      isConnected: false,
      userEmail: 'jeihanm@gmail.com',
      autoSync: false,
    );
  }

  static SupabaseConfig getDefaultSupabaseConfig() {
    return SupabaseConfig(
      url: defaultSupabaseUrl,
      publishableKey: defaultPublishableKey,
      isConnected: true,
      autoSync: true,
    );
  }

  // --- Task Groups ---
  static Future<List<TaskGroup>> loadTaskGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyTaskGroups);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((item) => TaskGroup.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore & return default
    }
    return getDefaultTaskGroups();
  }

  static Future<void> saveTaskGroups(List<TaskGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(groups.map((g) => g.toJson()).toList());
      await prefs.setString(_keyTaskGroups, raw);
    } catch (_) {}
  }

  // --- Pool Items ---
  static Future<List<PoolItem>> loadPoolItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyGeneratePool);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((item) => PoolItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore
    }
    return getDefaultPoolItems();
  }

  static Future<void> savePoolItems(List<PoolItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_keyGeneratePool, raw);
    } catch (_) {}
  }

  // --- Google Config ---
  static Future<GoogleSyncConfig> loadGoogleConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyGoogleConfig);
      if (raw != null && raw.isNotEmpty) {
        return GoogleSyncConfig.fromJson(jsonDecode(raw));
      }
    } catch (_) {}
    return getDefaultGoogleConfig();
  }

  static Future<void> saveGoogleConfig(GoogleSyncConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyGoogleConfig, jsonEncode(config.toJson()));
    } catch (_) {}
  }

  // --- Supabase Config ---
  static Future<SupabaseConfig> loadSupabaseConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keySupabaseConfig);
      if (raw != null && raw.isNotEmpty) {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        return SupabaseConfig(
          url: parsed['url'] ?? defaultSupabaseUrl,
          publishableKey: (parsed['publishableKey'] != null && (parsed['publishableKey'] as String).isNotEmpty)
              ? parsed['publishableKey']
              : defaultPublishableKey,
          isConnected: parsed['isConnected'] ?? true,
          autoSync: parsed['autoSync'] ?? true,
          lastSyncedAt: (parsed['lastSyncedAt'] as num?)?.toInt(),
        );
      }
    } catch (_) {}
    return getDefaultSupabaseConfig();
  }

  static Future<void> saveSupabaseConfig(SupabaseConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySupabaseConfig, jsonEncode(config.toJson()));
    } catch (_) {}
  }

  // --- Username & Theme ---
  static Future<String> loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername) ?? "Username";
    } catch (_) {
      return "Username";
    }
  }

  static Future<void> saveUsername(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, name);
    } catch (_) {}
  }

  static Future<String> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyTheme) ?? "basic";
    } catch (_) {
      return "basic";
    }
  }

  static Future<void> saveTheme(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, themeId);
    } catch (_) {}
  }

  // --- Auth Session ---
  static Future<bool> loadIsLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    } catch (_) {}
  }

  static Future<String> loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail) ?? "user@email.com";
    } catch (_) {
      return "user@email.com";
    }
  }

  static Future<void> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, email);
    } catch (_) {}
  }

  static Future<String?> loadUserPicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPicture);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserPicture(String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (url == null || url.isEmpty) {
        await prefs.remove(_keyUserPicture);
      } else {
        await prefs.setString(_keyUserPicture, url);
      }
    } catch (_) {}
  }

  static Future<void> clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserPicture);
      await prefs.setString(_keyUsername, "Username");
    } catch (_) {}
  }
}
