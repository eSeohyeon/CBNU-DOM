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
    apiKey: 'AIzaSyBXrbw6XOQp-tVSfgI_LhWtzkG-j2Smwbg',
    appId: '1:1088645974627:web:dd150be70490a4385ec656',
    messagingSenderId: '1088645974627',
    projectId: 'cbnu-dom',
    authDomain: 'cbnu-dom.firebaseapp.com',
    storageBucket: 'cbnu-dom.firebasestorage.app',
    measurementId: 'G-2F7DMKRVZJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARdNbxTZ3wFcew6Ptyy07mRSfAjKcsxV0',
    appId: '1:1088645974627:android:81f2e84437a4b7335ec656',
    messagingSenderId: '1088645974627',
    projectId: 'cbnu-dom',
    storageBucket: 'cbnu-dom.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADyHOBRX8tiRvBufLn_ITOdxaC1WoYgug',
    appId: '1:1088645974627:ios:348d4ad43a1b55295ec656',
    messagingSenderId: '1088645974627',
    projectId: 'cbnu-dom',
    storageBucket: 'cbnu-dom.firebasestorage.app',
    iosBundleId: 'com.example.untitled',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADyHOBRX8tiRvBufLn_ITOdxaC1WoYgug',
    appId: '1:1088645974627:ios:348d4ad43a1b55295ec656',
    messagingSenderId: '1088645974627',
    projectId: 'cbnu-dom',
    storageBucket: 'cbnu-dom.firebasestorage.app',
    iosBundleId: 'com.example.untitled',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBXrbw6XOQp-tVSfgI_LhWtzkG-j2Smwbg',
    appId: '1:1088645974627:web:d98a9e2978c20f3b5ec656',
    messagingSenderId: '1088645974627',
    projectId: 'cbnu-dom',
    authDomain: 'cbnu-dom.firebaseapp.com',
    storageBucket: 'cbnu-dom.firebasestorage.app',
    measurementId: 'G-1S3DJGWS45',
  );

}