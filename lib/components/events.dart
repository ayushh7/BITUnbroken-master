import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();

}

class _EventsPageState extends State<EventsPage> {
  final primaryColor=Color(0xFF0B3354);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _eventNameController = TextEditingController();
  DateTime _eventDate = DateTime.now(); // To store the event date and time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(primaryColor.value),
        title: Text('Events'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter event name',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _postEvent();
                  },
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Show a date picker and update _eventDate
              _selectDate(context);
            },
            child: Text(
              'Select Event Date and Time',
              style: TextStyle(color: primaryColor),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('events').orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index].data() as Map<String, dynamic>;
                    final eventName = event['name'];
                    final eventDate = event['date'];
                    final eventId = events[index].id;

                    return ListTile(
                      title: Text(eventName),
                      subtitle: Text(eventDate),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEvent(eventId);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _postEvent() {
    final user = _auth.currentUser;
    final eventName = _eventNameController.text;

    if (user != null && eventName.isNotEmpty) {
      _firestore.collection('events').add({
        'name': eventName,
        'date': _eventDate.toLocal().toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      _eventNameController.clear();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  void _deleteEvent(String eventId) {
    _firestore.collection('events').doc(eventId).delete();
  }
}
