import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreUserData {
  final String email;
  final String? username;
  final String? userPicture;
  final String? theme;
  final List<TaskGroup> taskGroups;
  final List<PoolItem> poolItems;

  FirestoreUserData({
    required this.email,
    this.username,
    this.userPicture,
    this.theme,
    required this.taskGroups,
    required this.poolItems,
  });
}

class FirestoreService {
  static const String _collection = 'users';

  static bool get _isTestEnv {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Load user data from Cloud Firestore.
  /// Returns [null] if the user does not exist yet (first-time user).
  static Future<FirestoreUserData?> fetchUserData(String email) async {
    if (_isTestEnv) return null;
    final cleanEmail = sanitizeEmail(email);
    if (cleanEmail.isEmpty) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(cleanEmail)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;

      // Parse taskGroups
      final rawGroups = data['taskGroups'] as List<dynamic>? ?? [];
      final List<TaskGroup> parsedGroups = rawGroups
          .map((g) => TaskGroup.fromJson(Map<String, dynamic>.from(g as Map)))
          .toList();

      // Parse poolItems
      final rawPool = data['poolItems'] as List<dynamic>? ?? [];
      final List<PoolItem> parsedPool = rawPool
          .map((p) => PoolItem.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();

      return FirestoreUserData(
        email: cleanEmail,
        username: data['username'] as String?,
        userPicture: data['userPicture'] as String?,
        theme: data['theme'] as String?,
        taskGroups: parsedGroups,
        poolItems: parsedPool,
      );
    } catch (e) {
      debugPrint("Firestore fetch error for $cleanEmail: $e");
      return null;
    }
  }

  /// Save or update user data in Cloud Firestore.
  static Future<bool> saveUserData({
    required String email,
    required List<TaskGroup> taskGroups,
    required List<PoolItem> poolItems,
    String? username,
    String? theme,
    String? userPicture,
  }) async {
    if (_isTestEnv) return true;
    final cleanEmail = sanitizeEmail(email);
    if (cleanEmail.isEmpty) return false;

    try {
      final Map<String, dynamic> data = {
        'email': cleanEmail,
        'taskGroups': taskGroups.map((g) => g.toJson()).toList(),
        'poolItems': poolItems.map((p) => p.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (username != null && username.isNotEmpty) {
        data['username'] = username;
      }
      if (theme != null && theme.isNotEmpty) {
        data['theme'] = theme;
      }
      if (userPicture != null) {
        data['userPicture'] = userPicture;
      }

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(cleanEmail)
          .set(data, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint("Firestore save error for $cleanEmail: $e");
      return false;
    }
  }

  /// Set up a real-time listener for user data in Cloud Firestore.
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? setupRealtimeSubscription(
    String email,
    void Function(FirestoreUserData) onData,
  ) {
    if (_isTestEnv) return null;
    final cleanEmail = sanitizeEmail(email);
    if (cleanEmail.isEmpty) return null;

    try {
      return FirebaseFirestore.instance
          .collection(_collection)
          .doc(cleanEmail)
          .snapshots()
          .listen(
        (snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return;
          final data = snapshot.data()!;

          final rawGroups = data['taskGroups'] as List<dynamic>? ?? [];
          final parsedGroups = rawGroups
              .map((g) => TaskGroup.fromJson(Map<String, dynamic>.from(g as Map)))
              .toList();

          final rawPool = data['poolItems'] as List<dynamic>? ?? [];
          final parsedPool = rawPool
              .map((p) => PoolItem.fromJson(Map<String, dynamic>.from(p as Map)))
              .toList();

          final user = FirestoreUserData(
            email: cleanEmail,
            username: data['username'] as String?,
            userPicture: data['userPicture'] as String?,
            theme: data['theme'] as String?,
            taskGroups: parsedGroups,
            poolItems: parsedPool,
          );

          onData(user);
        },
        onError: (err) {
          debugPrint("Firestore realtime subscription error: $err");
        },
      );
    } catch (e) {
      debugPrint("Firestore setup subscription error: $e");
      return null;
    }
  }
}
