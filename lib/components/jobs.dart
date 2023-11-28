import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';


class JobsPage extends StatefulWidget {

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final primaryColor=Color(0xFF0B3354);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    initUrlLauncher();
  }

  String jobTitle = "";
  String companyName = "";
  String link = "";

  void _createJob() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('jobs').add({
          'job_title': jobTitle,
          'company_name': companyName,
          'link': link,
          'uid': user.uid,
        });
        Navigator.of(context).pop(); // Close the dialog
        // Clear the input fields
        setState(() {
          jobTitle = "";
          companyName = "";
          link = "";
        });
      } catch (e) {
        print("Error creating job: $e");
      }
    }
  }
  void initUrlLauncher() async {
    if (await canLaunch('https://example.com')) {
      // Do nothing, just initialization
    }
  }
  void _showCreateJobDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create Job"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Job Title'),
                onChanged: (value) {
                  setState(() {
                    jobTitle = value;
                  });
                },
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Company Name'),
                onChanged: (value) {
                  setState(() {
                    companyName = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Link'),
                onChanged: (value) {
                  setState(() {
                    link = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close"),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
            ),
            ElevatedButton(
              onPressed: _createJob,
              child: Text("Post Job"),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Job Postings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('jobs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final jobs = snapshot.data!.docs;
          List<Widget> jobCards = [];
          for (var job in jobs) {
            final jobTitle = job['job_title'];
            final companyName = job['company_name'];
            final link = job['link']; // Fetch the link from Firestore
            jobCards.add(
              Card(
                child: ListTile(
                  title: Text(jobTitle),
                  subtitle: Text(companyName),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final url = link;

                      try {
                        await launch(
                          url,
                          forceSafariVC: false,  // Try opening in Safari (iOS) or Chrome (Android)
                          forceWebView: false,  // Try opening in a WebView
                        );
                      } catch (e) {
                        // Handle the error gracefully, e.g., show an error dialog or log the error.
                        print('Error launching URL: $e');
                        // You can also show an error message to the user.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open the URL. Please check your internet connection or try again later.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                    ),
                    child: Text('Apply'),
                  )


                ),
              ),
            );
          }
          return Column(
            children: jobCards,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(

        onPressed: _showCreateJobDialog,
        backgroundColor: primaryColor,

        child: Icon(Icons.add),

      ),
    );
  }
}
