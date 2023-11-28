// import 'package:firebase_core/firebase_core.dart';
// import 'package:bitunbroken/screens/Profile.dart';
// import 'package:flutter/material.dart';
// import 'package:bitunbroken/screens/login_screen.dart';
// import 'package:bitunbroken/screens/signup_screen.dart';
// import 'package:bitunbroken/screens/home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase initialization
// //   await Firebase.initializeApp(
// //     options: FirebaseOptions(
// //       apiKey: 'AIzaSyBj8oJBUyUnWvgkGs9NLmFd_vnVIk6RIcM',
// //       appId: '1:181505050880:android:5c94ac4fdfbd5186730be5',
// //       messagingSenderId: '181505050880',
// //       projectId: 'bitunbroken',
// //       databaseURL: 'https://bitunbroken-default-rtdb.asia-southeast1.firebasedatabase.app/', // Update this URL
// //     ),
// //   );
// //   runApp(BitUnbrokenApp());
// // }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//
//   // Add code to retrieve the authenticated user
//   User? user = FirebaseAuth.instance.currentUser;
//
//   runApp(BitUnbrokenApp(user: user)); // Pass the user object to the widget
// }
//
// class BitUnbrokenApp extends StatelessWidget {
//   final User? user; // Declare user as an optional parameter
//
//   BitUnbrokenApp({this.user}); // Update the constructor to accept user
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'BitUnbroken',
//       theme: ThemeData(
//         primaryColor: Colors.black,
//       ),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginPage(),
//         '/signup': (context) => SignUpPage(),
//         '/home': (context) => HomePage(user: user),
//         // '/home': (context) => HomePage(user: user ?? User(uid: "")), // Pass the user to HomePage
//         '/profile': (context) => ProfilePage(),
//       },
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bitunbroken/screens/login_screen.dart';
import 'package:bitunbroken/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(BitUnbrokenApp());
}

class BitUnbrokenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BitUnbroken',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: AuthenticationWrapper(),
    );


  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? LoginPage() : HomePage(user: user);
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
