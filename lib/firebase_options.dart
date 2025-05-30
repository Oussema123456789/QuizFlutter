// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJN9lrDACvlfUp9knko4gUfriaDki6t3g',
    appId: '1:324196767093:web:bd632d65004a4d5846ef3c',
    messagingSenderId: '324196767093',
    projectId: 'flutter-775c2',
    storageBucket: 'quiz-6bc10.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyCJN9lrDACvlfUp9knko4gUfriaDki6t3g",
      authDomain: "flutter-775c2.firebaseapp.com",
      projectId: "flutter-775c2",
      storageBucket: "flutter-775c2.firebasestorage.app",
      messagingSenderId: "324196767093",
      appId: "1:324196767093:web:bd632d65004a4d5846ef3c",
      measurementId: "G-NDR8RGEPXG"
  );
}
