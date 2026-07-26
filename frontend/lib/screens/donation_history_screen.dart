import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  late Stream<DocumentSnapshot> _userStream;
  List<Map<String, dynamic>> _donationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      _userStream = FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .snapshots();

      // Load donation history if it exists in a separate collection
      FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .collection('donations')
          .orderBy('donationDate', descending: true)
          .get()
          .then((querySnapshot) {
        setState(() {
          _donationHistory = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
      }).catchError((error) {
        print("Error loading donation history: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          
          if (userData == null) {
            return Center(child: Text('No donation history available'));
          }

          final lastDonation = userData['Last Blood Donation'] ?? 'Never';
          final totalDonations = _donationHistory.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User summary card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData['Full Name'] ?? 'User'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Blood Group: ${userData['Blood Group'] ?? 'Not specified'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Last Donation: $lastDonation',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Donations: $totalDonations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Donation History List
                Text(
                  'Donation History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                Expanded(
                  child: _donationHistory.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bloodtype_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No donation records found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your donation history will appear here',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _donationHistory.length,
                          itemBuilder: (context, index) {
                            final donation = _donationHistory[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Icon(
                                    Icons.bloodtype,
                                    color: Colors.red,
                                  ),
                                ),
                                title: Text(
                                  'Donation ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    if (donation['donationDate'] != null)
                                      Text(
                                        'Date: ${_formatDate(donation['donationDate'])}',
                                      ),
                                    if (donation['location'] != null)
                                      Text(
                                        'Location: ${donation['location']}',
                                      ),
                                    if (donation['verified'] != null)
                                      Text(
                                        donation['verified'] == true
                                            ? 'Status: ✅ Verified'
                                            : 'Status: ⏳ Pending',
                                        style: TextStyle(
                                          color: donation['verified'] == true
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      // Add this button to test adding a donation (for development)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTestDonation();
        },
        tooltip: 'Add Test Donation',
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    } else if (date is String) {
      return date;
    }
    return 'Date not available';
  }

  // Test function to add a donation record (for development)
  Future<void> _addTestDonation() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .collection('donations')
          .add({
        'donationDate': Timestamp.now(),
        'location': 'Test Hospital',
        'verified': true,
        'addedOn': FieldValue.serverTimestamp(),
      });

      // Refresh the list
      _loadUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test donation added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}