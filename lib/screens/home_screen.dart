import 'package:bitunbroken/screens/users_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../components/events.dart';
import '../components/jobs.dart';
import 'Profile.dart';
import 'login_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;
const _subscriptDelimiter = '\u2080';

class HomePage extends StatefulWidget {
  final User? user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final primaryColor=Color(0xFF0B3354);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<_HomePageState> homeScreenKey = GlobalKey<_HomePageState>();


  String imageUrl = '';

  // Handle back button press
  Future<bool> _onBackPressed() {
    if (_selectedIndex != 0) {
      // If not in the first tab, navigate to the first tab
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false); // Do not close the app
    }
    return Future.value(true); // Close the app if already in the first tab
  }

  int _selectedIndex = 0;

  String userName = "User"; // Default name if not found

  bool _isLoading = false;
  List<DocumentSnapshot> _posts = []; // Store the loaded posts
  int _postBatchSize = 10;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  String passingBatch = '';
  void fetchUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        print("Fetching user data for UID: ${user.uid}");
        if (documentSnapshot.exists) {
          print("User data found: ${documentSnapshot.data()}");
          setState(() {
            userName = documentSnapshot['name'];
            passingBatch = documentSnapshot['passingBatch'] ?? '';
          });
        } else {
          print("User data not found for UID: ${user.uid}");
        }
      });
    } else {
      print("User is not authenticated.");
    }
  }
  String getPassingBatch() {
    return passingBatch.isNotEmpty ? '$_subscriptDelimiter$passingBatch' : '';
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        key: homeScreenKey,
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Unbroken'),
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                icon: Icon(Icons.event,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.search,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.work,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobsPage()),
                  );
                  // Handle Jobs button action
                },
              ),
              IconButton(
                icon: Icon(Icons.logout,), // Add a sign-out button
                onPressed: () {
                  _signOut(context);
                },
              ),
            ],
          ),

            body: Stack(
              children: [
                // Background Image
                Image.asset(
                  'assets/images/background8.jpg', // Replace with the path to your image asset
                  fit: BoxFit.cover, // You can adjust the fit as needed
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Your existing content
                _buildPage(_selectedIndex, imageUrl),
              ],
            ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            selectedItemColor: primaryColor,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ));
  }

  Widget _buildPage(int index, String imageUrl) {
    if (index == 0) {return RefreshIndicator(
      onRefresh: _refreshData,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((postDocument) {
              final data = postDocument.data() as Map<String, dynamic>;
              final username = data['uid'];
              final text = data['text'] ?? "";
              final imageUrls = List<String>.from(data['images'] ?? []);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(username).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    // return CircularProgressIndicator();
                  }

                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }

                  if (!userSnapshot.hasData) {
                    return Text('No user data found');
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['name'] ?? "";
                  final email = userData['email'] ?? "";
                  final postContent = text;
                  final post = Post(name, postContent, imageUrls: imageUrls, passingBatch: passingBatch);

                  return PostWidget(post: post, imageUrl: imageUrl, currentUser: widget.user, postDocument: postDocument, passingBatch: getPassingBatch());
                },
              );
            }).toList(),
          );
        },
      ),
    );

    } else if (index == 1) {
      return AddPostWidget(user: widget.user);
    } else if (index == 2) {
      return ProfilePage(
        user: widget.user,
        onImageUrlChanged: (newImageUrl) {
          setState(() {
            imageUrl = newImageUrl;
          });
        },
      );
    }

    return Container();
  }

  Future<void> _refreshData() async {
    // Fetch the latest data here, for example, refetch posts from Firestore
    // Replace this with your actual data fetching logic
    await _loadPosts();
  }
  Future<void> _loadPosts() async {
    // Fetch posts in batches
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_postBatchSize)
        .get();

    setState(() {
      _posts = querySnapshot.docs;
    });
  }
}



class AddPostWidget extends StatefulWidget {
  final User? user;

  AddPostWidget({required this.user});

  @override
  _AddPostWidgetState createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends State<AddPostWidget> {
  String postText = "";
  List<String> postImages = [];

  TextEditingController _textEditingController = TextEditingController();
  FocusNode _textFocusNode = FocusNode();

  void _createPost() async {
    if (postText.isNotEmpty || postImages.isNotEmpty) {
      List<String> downloadUrls = [];

      // Upload images to Firestore
      for (var imagePath in postImages) {
        final ref = FirebaseStorage.instance.ref().child('post_images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = ref.putFile(File(imagePath));

        await uploadTask.whenComplete(() async {
          final url = await ref.getDownloadURL();
          downloadUrls.add(url);
        });
      }

      // Add post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': widget.user?.uid,
        'text': postText,
        'images': downloadUrls, // Store download URLs of images
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        postText = "";
        postImages.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post created successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openImagePicker() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        postImages.add(pickedFile.path);
      });
    }
  }

  void _showFormattingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.format_bold),
                title: Text('Bold'),
                onTap: () {
                  _formatText('**', '**');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.format_italic),
                title: Text('Italic'),
                onTap: () {
                  _formatText('*', '*');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.format_clear),
                title: Text('Clear Formatting'),
                onTap: () {
                  _formatText('', '');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Add Image'),
                onTap: () {
                  _openImagePicker();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _formatText(String startTag, String endTag) {
    final currentText = _textEditingController.text;
    final selection = _textEditingController.selection;

    final newText =
        currentText.substring(0, selection.start) + startTag + currentText.substring(selection.start, selection.end) + endTag + currentText.substring(selection.end);

    setState(() {
      postText = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            focusNode: _textFocusNode,
            maxLines: null,
            style:TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: "Create Post...",
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.format_align_left),
                onPressed: _showFormattingOptions,
              ),
            ),
            onChanged: (text) {
              setState(() {
                postText = text;
              });
            },
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: postImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Image.file(
                    File(postImages[index]),
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          postImages.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _createPost();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text("Post", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class Post {
  final String username;
  final String content;
  final List<String> imageUrls; // List of image URLs
  final String passingBatch;

  Post(this.username, this.content, {required this.imageUrls, required this.passingBatch});
}
class PostWidget extends StatelessWidget {
  final Post post;
  final DocumentSnapshot postDocument;
  final String imageUrl;
  final User? currentUser;
  final String passingBatch;// Pass the current user to the widget

  PostWidget({required this.post, required this.imageUrl, required this.currentUser, required this.postDocument,required this.passingBatch});
  Future<String> fetchPassingBatch() async {
    // Add the logic to fetch passingBatch from Firebase
    // Example:
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(post.username).get();
    final passingBatch = userDoc['passingBatch'] ?? '';
    return passingBatch;
  }
  void _deletePost(BuildContext context, String postDocId) async {
    if (postDocId != null && post.username == currentUser?.uid) {
      // Check if the current user is the creator of the post and the postDocId is not null
      await FirebaseFirestore.instance.collection('posts').doc(postDocId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to delete this post'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/background4.jpg'),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: post.username,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(-20, 15), // Adjust the vertical offset as needed
                      // child: Text(
                      //   post.passingBatch,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 10, // Adjust the fontSize as needed
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
            )


          ),

          Padding(
            padding: EdgeInsets.all(8),
            child: Text(post.content),
          ),
          if (post.imageUrls.isNotEmpty)
            Container(
              height: 400, // Adjust the height as needed
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 16), // Adjust the horizontal padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Adjust the border radius as needed
                      child: Image.network(
                        post.imageUrls[index],
                        width: 320, // Adjust the width as needed
                        height: 400, // Adjust the height as needed based on the aspect ratio
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          if (post.username == currentUser?.uid) // Display the delete icon for the post creator
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deletePost(context, postDocument.id); // Pass the document ID
              },
            ),

        ],
      ),
    );
  }
}
