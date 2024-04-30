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
    apiKey: 'AIzaSyC-eXH1mcTbeXUbovYH5to_ysUSbAnpfmI',
    appId: '1:161800419142:web:9031fb5c3f932fba209747',
    messagingSenderId: '161800419142',
    projectId: 'travel-season-54aac',
    authDomain: 'travel-season-54aac.firebaseapp.com',
    storageBucket: 'travel-season-54aac.appspot.com',
    measurementId: 'G-JS9R3HHM9L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWTsZSqWwpbjZcu011eAx2W6v_qU7Ocz8',
    appId: '1:161800419142:android:21c832e902b5d072209747',
    messagingSenderId: '161800419142',
    projectId: 'travel-season-54aac',
    storageBucket: 'travel-season-54aac.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIDXq2TVG-URJMGQEqNmyMO__q4I01InY',
    appId: '1:161800419142:ios:ae5a8a13fdf2411b209747',
    messagingSenderId: '161800419142',
    projectId: 'travel-season-54aac',
    storageBucket: 'travel-season-54aac.appspot.com',
    iosBundleId: 'com.example.travelzone',
  );
}
