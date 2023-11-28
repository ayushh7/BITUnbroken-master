import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final primaryColor=Color(0xFF0B3354);
  List<DocumentSnapshot> users = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      // Update the list when the search text changes
      fetchUsers(searchController.text);
    });
  }

  void fetchUsers(String search) {
    FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: search)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        users = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Search People'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,style: TextStyle(color: primaryColor),
              decoration: InputDecoration(labelText: 'Search by Name'),
            ),
          ),
          Expanded(
            child: ListView(
              children: users
                  .map((user) => ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']), // or other user info
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
