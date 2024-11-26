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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBTJ9QvbFAeye6MW_NeaCHxjrwwOMXwH2Y',
    appId: '1:65911745801:web:405ae217afd98e51f2b7d8',
    messagingSenderId: '65911745801',
    projectId: 'foodping-9394b',
    authDomain: 'foodping-9394b.firebaseapp.com',
    storageBucket: 'foodping-9394b.firebasestorage.app',
    measurementId: 'G-X0CYKBQZGK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgzjPrOx0nnzE34AYr0VNOlHLyjX_aSlw',
    appId: '1:65911745801:android:fb1f3d020a1341e3f2b7d8',
    messagingSenderId: '65911745801',
    projectId: 'foodping-9394b',
    storageBucket: 'foodping-9394b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDypBvVOW13QBD0HxeHFJ8VWslXTFArP2E',
    appId: '1:65911745801:ios:db5595d5527b3a90f2b7d8',
    messagingSenderId: '65911745801',
    projectId: 'foodping-9394b',
    storageBucket: 'foodping-9394b.firebasestorage.app',
    iosBundleId: 'com.example.nyumNyumPing',
  );
}