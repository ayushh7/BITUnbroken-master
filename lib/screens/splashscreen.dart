import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Replace the duration with the desired delay
    Timer(
      Duration(seconds: 2), // Change the duration as needed
          () => Navigator.of(context).pushReplacementNamed('/login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(

        child:Container(
          height: 200,
          width: 400,
          child: Image.asset('assets/images/logo.png'),

          // Replace with your logo path
        )
      ),

    );
  }
}
