import 'package:flutter/material.dart';
import 'package:proconnect/Views/Auth/LoginPage.Dart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBR28oRRfCEscOHynXGUuQG-f-HkpbhXEE",
          authDomain: "proconnect-2fd18.firebaseapp.com",
          databaseURL: "https://proconnect-2fd18-default-rtdb.firebaseio.com",
          appId: "1:833804354243:web:782e2f09f832fd1dcd1876",
          storageBucket: "proconnect-2fd18.appspot.com",
          messagingSenderId: "833804354243",
          projectId: "proconnect-2fd18",
          measurementId: "G-DZ3R81N3TL"));
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
        home: const LoginPage(),
      ),
    );
  }
}
