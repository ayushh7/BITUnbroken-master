import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'home_screen.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _name;
  String? _email;
  String? _password;
  String? _phoneNumber;
  String? _passingBatch;
  String? _currentDesignation;

  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> _showSuccessAndSignIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = await _auth.registerWithEmailAndPassword(_email!, _password!);

        if (user != null) {
          await _userCollection.doc(user.uid).set({
            'name': _name,
            'email': _email,
            'phoneNumber': _phoneNumber,
            'passingBatch': _passingBatch,
            'currentDesignation': _currentDesignation,
          }
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged in successfully'),
              duration: Duration(seconds: 2), // Adjust the duration as needed
            ),

          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(user: FirebaseAuth.instance.currentUser),
          ));

        }
      } catch (error) {
        print('Error during registration and login: $error');
        // Handle registration/login errors here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/images/background8.jpg'), // Replace with your image path
        fit: BoxFit.cover,
          ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to BITUnbroken!',
                  style: TextStyle(color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    _name = value;
                  },
                  style: TextStyle(color: Colors.black),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty??true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    _email = value;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty?? true) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    _password = value;
                  },
                  obscureText: true, style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty?? true) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    _phoneNumber = value;
                  },style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  onChanged: (value) {
                    _passingBatch = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Passing Batch',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                  ),
                  items: List.generate(86, (index) {
                    final year = 2030 - index;
                    return DropdownMenuItem<String>(
                      value: year.toString(),
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your passing batch';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    _currentDesignation = value;
                  }, style: TextStyle(color: Colors.black),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Enter your current designation',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(
                      Icons.work,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _showSuccessAndSignIn(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF070707),
                      shape: StadiumBorder(),
                    ),
                    child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  // child: ElevatedButton.icon(
                  //   onPressed: () {
                  //     // Add Google Sign-In logic here
                  //   },
                  //
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xFFF6F2F2),
                  //     shape: StadiumBorder(),
                  //   ),
                  //   icon: Icon(
                  //     FontAwesomeIcons.google,
                  //     color: Colors.white,
                  //   ),
                  //   // label: Text('Sign Up with Google', style: TextStyle(color: Colors.white)),
                  // ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
