// ──────────────────────────────────────────────────────────────
// PLACEHOLDER — replace with the output of `flutterfire configure`
// ──────────────────────────────────────────────────────────────
//
// Steps:
//   1. Install the FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//   2. Run:
//        flutterfire configure
//   3. Replace this file with the generated firebase_options.dart
// ──────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name} — run `flutterfire configure` '
          'to generate this file.',
        );
    }
  }

  // ── Replace these placeholder values ──

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVv5JnKfWkhp1PpcMgeIr8Pu9yQoN4Mmk',
    appId: '1:415273004224:android:29b7ee1b4d86ddb53a5125',
    messagingSenderId: '415273004224',
    projectId: 'ultra-optics-447502-a2',
    storageBucket: 'ultra-optics-447502-a2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'com.itclub.collegeClubApp',
  );
}
