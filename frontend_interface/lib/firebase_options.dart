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
    apiKey: 'AIzaSyDRrbLzvIqFcevsWyM-YDFInGQbECmK0IM',
    appId: '1:614858092139:web:98cfbe00c8e5367f5f4b2e',
    messagingSenderId: '614858092139',
    projectId: 'smart2025',
    authDomain: 'smart2025.firebaseapp.com',
    storageBucket: 'smart2025.firebasestorage.app',
    measurementId: 'G-ZJ2PM7ZJHH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPX1AtZHxXSqqdIeqkoUt4PofnTXINrBs',
    appId: '1:614858092139:android:3aa77125411c00855f4b2e',
    messagingSenderId: '614858092139',
    projectId: 'smart2025',
    storageBucket: 'smart2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4YfxTx-kYiyM3-Bf1BBJnCWacmtM3OBY',
    appId: '1:614858092139:ios:1ad32902186d444c5f4b2e',
    messagingSenderId: '614858092139',
    projectId: 'smart2025',
    storageBucket: 'smart2025.firebasestorage.app',
    iosBundleId: 'com.example.frontendInterface',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4YfxTx-kYiyM3-Bf1BBJnCWacmtM3OBY',
    appId: '1:614858092139:ios:1ad32902186d444c5f4b2e',
    messagingSenderId: '614858092139',
    projectId: 'smart2025',
    storageBucket: 'smart2025.firebasestorage.app',
    iosBundleId: 'com.example.frontendInterface',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDRrbLzvIqFcevsWyM-YDFInGQbECmK0IM',
    appId: '1:614858092139:web:b26f74f462d61e235f4b2e',
    messagingSenderId: '614858092139',
    projectId: 'smart2025',
    authDomain: 'smart2025.firebaseapp.com',
    storageBucket: 'smart2025.firebasestorage.app',
    measurementId: 'G-64FJCTWTKW',
  );
}
