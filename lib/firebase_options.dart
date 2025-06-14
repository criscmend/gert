// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACGpxztGC4PYGX1PTJg62J5yccdPIWiSs',
    appId: '1:147850415247:web:16892caa4d1994c6e6b4fa',
    messagingSenderId: '147850415247',
    projectId: 'gert-fa76a',
    authDomain: 'gert-fa76a.firebaseapp.com',
    storageBucket: 'gert-fa76a.firebasestorage.app',
    measurementId: 'G-3SLNZPBBLX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJ8ymZHA3Ik52Jt-c-u-n75zc_zy9coUk',
    appId: '1:147850415247:android:50491389d8311b22e6b4fa',
    messagingSenderId: '147850415247',
    projectId: 'gert-fa76a',
    storageBucket: 'gert-fa76a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0npNZnifhW3mxqc-RLP1_49zpEVuBk2E',
    appId: '1:147850415247:ios:5e6d7b436e3c0fede6b4fa',
    messagingSenderId: '147850415247',
    projectId: 'gert-fa76a',
    storageBucket: 'gert-fa76a.firebasestorage.app',
    iosBundleId: 'com.example.gertApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD0npNZnifhW3mxqc-RLP1_49zpEVuBk2E',
    appId: '1:147850415247:ios:5e6d7b436e3c0fede6b4fa',
    messagingSenderId: '147850415247',
    projectId: 'gert-fa76a',
    storageBucket: 'gert-fa76a.firebasestorage.app',
    iosBundleId: 'com.example.gertApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyACGpxztGC4PYGX1PTJg62J5yccdPIWiSs',
    appId: '1:147850415247:web:bffac0e04033f3ece6b4fa',
    messagingSenderId: '147850415247',
    projectId: 'gert-fa76a',
    authDomain: 'gert-fa76a.firebaseapp.com',
    storageBucket: 'gert-fa76a.firebasestorage.app',
    measurementId: 'G-6559ETBNT1',
  );
}
