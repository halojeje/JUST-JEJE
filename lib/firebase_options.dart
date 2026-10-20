import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project `chao571-todolist-project2026`.
///
/// Salin nilai apiKey, appId, dan messagingSenderId dari:
/// https://console.firebase.google.com/u/1/project/chao571-todolist-project2026/settings/general
class DefaultFirebaseOptions {
  static const String projectId = 'chao571-todolist-project2026';
  static const String authDomain = 'chao571-todolist-project2026.firebaseapp.com';
  static const String storageBucket = 'chao571-todolist-project2026.firebasestorage.app';

  static const String apiKey = 'AIzaSyCgBcOppDc_ZVVHpASquy8XSd_s8MMFFvI';
  static const String appId = '1:316022951975:web:c4a7e1ca45d13aec74fe02';
  static const String messagingSenderId = '316022951975';
  static const String measurementId = 'G-Z2KHD77M8Y';

  static bool get isConfigured => true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4BxdeRe0FbojEzTvkukHwLNhK4GuqBKg',
    appId: '1:316022951975:android:e89e951912475e9574fe02',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.example.justJeje',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.example.justJeje',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );
}
