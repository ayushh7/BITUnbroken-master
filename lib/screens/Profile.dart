import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:io';

class ProfilePage extends StatefulWidget {
  final User? user;

  final Function(String) onImageUrlChanged;

  ProfilePage({required this.user, required this.onImageUrlChanged});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final primaryColor=Color(0xFF0B3354);
  String currentDesignation = '';
  String email = '';
  String name = '';
  String passingBatch = '';
  String phoneNumber = '';
  String imageUrl = '';
  final CollectionReference _userRef =
  FirebaseFirestore.instance.collection('users');

  Future<void> fetchUserData() async {
    try {
      final userUid = widget.user?.uid;
      if (userUid != null) {
        final userDoc = await _userRef.doc(userUid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            currentDesignation = userData['currentDesignation'] ?? '';
            email = userData['email'] ?? '';
            name = userData['name'] ?? '';
            passingBatch = userData['passingBatch'] ?? '';
            phoneNumber = userData['phoneNumber'] ?? '';
            imageUrl = userData['imageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${widget.user?.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();

        await _userRef.doc(widget.user?.uid).update({
          'imageUrl': imageUrl,
        });

        setState(() {
          this.imageUrl = imageUrl;
        });

        // Call the callback function to send imageUrl to the parent widget
        widget.onImageUrlChanged(imageUrl);
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background8.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: Column(
              children: [
                SizedBox(height: 55),
                GestureDetector(
                  onTap: () {
                    pickAndUploadImage();
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrl, // URL of the image to load and cache
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 50,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(), // Loading placeholder
                    errorWidget: (context, url, error) => Icon(Icons.error), // Error placeholder
                  ),

                ),

                SizedBox(height: 150),
                Text(
                  'Name: $name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: $email',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Current Designation: $currentDesignation',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Passing Batch: $passingBatch',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone Number: $phoneNumber',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height:260),
                Text('Created by Ayush Singh', style: TextStyle(fontWeight: FontWeight.bold),)
                // Positioned(
                //   bottom: 10,
                //   right: 20,
                //   child: FloatingActionButton(
                //     backgroundColor: primaryColor,
                //     onPressed: pickAndUploadImage,
                //     child: Icon(Icons.photo_camera, color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),

        ],
      ),

    );
  }
}
