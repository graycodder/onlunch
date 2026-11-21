import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for OneLunch connecting to Rinus Food Products Firebase
/// Project: rfproducts-e76ce
class DefaultFirebaseOptions {
  static const String databaseURL =
      'https://rfproducts-e76ce-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const String projectId = 'rfproducts-e76ce';
  static const String storageBucket = 'rfproducts-e76ce.firebasestorage.app';

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAa2iHqOY6jyEpipSOfYrNokbsrcgyXl5w',
    appId: '1:914601842477:web:19ae51923e8a6f20e9a5a4',
    messagingSenderId: '914601842477',
    projectId: projectId,
    authDomain: 'rfproducts-e76ce.firebaseapp.com',
    databaseURL: databaseURL,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAa2iHqOY6jyEpipSOfYrNokbsrcgyXl5w',
    appId: '1:914601842477:android:eb20f04589ba7498e9a5a4',
    messagingSenderId: '914601842477',
    projectId: projectId,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNsX968K-UNGYnFCYHO5Nx7PFBSlv4ILM',
    appId: '1:914601842477:ios:19ae51923e8a6f20e9a5a4',
    messagingSenderId: '914601842477',
    projectId: projectId,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    iosBundleId: 'com.rinusfood.onelunch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCNsX968K-UNGYnFCYHO5Nx7PFBSlv4ILM',
    appId: '1:914601842477:ios:19ae51923e8a6f20e9a5a4',
    messagingSenderId: '914601842477',
    projectId: projectId,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    iosBundleId: 'com.rinusfood.onelunch',
  );
}

