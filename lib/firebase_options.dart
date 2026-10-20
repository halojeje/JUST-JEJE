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

  // Masukkan API Key & App ID dari Firebase Console -> Project Settings -> General
  static const String apiKey = 'YOUR_FIREBASE_API_KEY';
  static const String appId = 'YOUR_FIREBASE_APP_ID';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';

  static bool get isConfigured =>
      apiKey.isNotEmpty && !apiKey.startsWith('YOUR_');

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
    apiKey: apiKey,
    appId: appId,
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
