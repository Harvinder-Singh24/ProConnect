import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proconnect/Views/Home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/constants.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool isAuthenticated;
  late SharedPreferences prefs;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");

  @override
  void initState() {
    super.initState();
    isAuthenticated = false;
    initializePreferences();
    initalizeAuth0web();
  }

  Future<void> initalizeAuth0web() async {
    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => {
            if (credentials != null) {}
            // Not logged in
          });
    }
    setState(() {});
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    setState(() {});
  }

  Future<void> updateAuthenticationStatus(bool status) async {
    await prefs.setBool('isAuthenticated', status);
    setState(() {
      isAuthenticated = status;
    });
  }

  Future<void> _sendUserDataToFirebase(
      String? name, String userId, Uri? profielUrl) async {
    await _usersRef.push().set({
      'name': name,
      "userId": userId,
      "profilePic": profielUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ProConnect Tv',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meet With Professionals the Easy Way',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              isAuthenticated
                  ? ElevatedButton(
                      onPressed: () async {
                        final credentials = await auth0Web.credentials();
                        String? name = credentials.user.name;
                        Uri? profileUrl = credentials.user.profileUrl;
                        String userId =
                            credentials.user.sub.replaceAll('linkedin|', '');
                        print("User Id of the Current User is ${userId}");

                        _sendUserDataToFirebase(name, userId, profileUrl)
                            .whenComplete(() => {
                                  print("Sucessfull data Sent"),
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                  ),
                                });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Get Started'))
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          // Show loading indicator or handle the UI accordingly
                          const CircularProgressIndicator();
                        });

                        if (kIsWeb) {
                          await auth0Web.loginWithRedirect(
                              redirectUrl: 'http://localhost:8080');
                        }

                        // After successful login, update authentication status
                        await updateAuthenticationStatus(true);
                      },
                      child: const Text('Log In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
