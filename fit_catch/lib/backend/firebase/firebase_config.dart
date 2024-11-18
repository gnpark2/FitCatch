import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCa1mjtsz1tlooLO8SznJqNlyoSYV2AkLU",
            authDomain: "fitcatch-2a15e.firebaseapp.com",
            projectId: "fitcatch-2a15e",
            storageBucket: "fitcatch-2a15e.firebasestorage.app",
            messagingSenderId: "445083312906",
            appId: "1:445083312906:web:45f9e3e3c513e580b950f3",
            measurementId: "G-3W0KZ8CMYN"));
  } else {
    await Firebase.initializeApp();
  }
}
