import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentIndex = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // User data variables
  String userName = 'Loading...';
  String userBloodType = 'Loading...';
  String lastDonationDate = 'Loading...';
  String userEmail = '';
  String userPhone = '';
  String userAddress = '';
  String userCNIC = '';
  bool healthIssue = false;
  
  // Donation history
  List<Map<String, dynamic>> donationHistory = [];
  
  // Edit mode
  bool isEditing = false;
  bool isLoading = true;
  String? errorMessage;
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final user = _auth.currentUser;
      print('Current user UID: ${user?.uid}');
      
      if (user == null) {
        setState(() {
          errorMessage = 'No user logged in';
          isLoading = false;
        });
        return;
      }

      final userDoc = await _firestore.collection('User').doc(user.uid).get();
      
      print('User document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        final data = userDoc.data()!;
        print('User data from Firestore: $data');
        
        setState(() {
          // Match field names exactly as in saveUserDataToFirestore()
          userName = data['Full Name'] ?? data['name'] ?? 'Not provided';
          userBloodType = data['Blood Group'] ?? data['bloodGroup'] ?? 'Unknown';
          userEmail = user.email ?? data['Email'] ?? 'Not provided';
          userPhone = data['Phone Number'] ?? data['phoneNumber'] ?? 'Not provided';
          userAddress = data['Current Address'] ?? data['address'] ?? 'Not provided';
          userCNIC = data['CNIC Number'] ?? 'Not provided';
          healthIssue = data['Health Issue'] ?? 'None';
          
          // Last blood donation - this is a single field, not an array
          lastDonationDate = data['Last Blood Donation'] ?? 'No donations yet';
          
          // If you have donation history as a separate field/collection
          // For now, we'll use the single 'Last Blood Donation' field
          donationHistory = [];
          if (lastDonationDate != 'No donations yet' && lastDonationDate != 'Loading...') {
            donationHistory.add({
              'type': 'Blood Donation',
              'date': lastDonationDate,
              'location': 'Blood Bank'
            });
          }
          
          isLoading = false;
        });
      } else {
        print('User document does not exist in Firestore');
        setState(() {
          errorMessage = 'User profile not found in database';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        errorMessage = 'Error loading profile: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update with the correct field names from saveUserDataToFirestore()
        await _firestore.collection('User').doc(user.uid).update({
          'Full Name': _nameController.text.isNotEmpty ? _nameController.text : userName,
          'Phone Number': _phoneController.text.isNotEmpty ? _phoneController.text : userPhone,
          'Current Address': _addressController.text.isNotEmpty ? _addressController.text : userAddress,
          'Blood Group': _bloodTypeController.text.isNotEmpty ? _bloodTypeController.text : userBloodType,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Reload data
        await _loadUserData();
        
        setState(() {
          isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startEditing() {
    _nameController.text = userName != 'Loading...' && userName != 'Not provided' ? userName : '';
    _phoneController.text = userPhone != 'Loading...' && userPhone != 'Not provided' ? userPhone : '';
    _addressController.text = userAddress != 'Loading...' && userAddress != 'Not provided' ? userAddress : '';
    _bloodTypeController.text = userBloodType != 'Loading...' && userBloodType != 'Unknown' ? userBloodType : '';
    
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: isEditing
            ? [
                IconButton(
                  onPressed: _cancelEditing,
                  icon: Icon(Icons.close),
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (errorMessage != null)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(errorMessage!),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              
              if (isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading profile...'),
                      ],
                    ),
                  ),
                )
              else ...[
                SizedBox(height: 10),
                
                // profile picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black26,
                  child: CircleAvatar(
                    radius: 59,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 64),
                  ),
                ),
                
                
                SizedBox(height: 14),
                
                // name of user - editable if in edit mode
                if (isEditing)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  )
                else
                  Text(
                    userName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                
                SizedBox(height: 2),
                
                // email (not editable)
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                
                SizedBox(height: 2),
                
                // blood type - editable if in edit mode
                if (isEditing)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        controller: _bloodTypeController,
                        decoration: InputDecoration(
                          labelText: 'Blood Group (e.g., O+, A-, etc.)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Blood Type: $userBloodType',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                
                SizedBox(height: 2),
                
                // last donation date
                Text(
                  'Last Donation: $lastDonationDate',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                
                SizedBox(height: 18),
                
                // edit profile button or save/cancel buttons
                if (isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _cancelEditing,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(99),
                            ),
                            padding: EdgeInsets.all(14),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: _updateUserProfile,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            padding: EdgeInsets.all(14),
                            child: Center(
                              child: Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: _startEditing,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      padding: EdgeInsets.all(14),
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: 20),
                
                // Additional editable fields when in edit mode
                if (isEditing) ...[
                  SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  
                  SizedBox(height: 10),
                  
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 2,
                  ),
                  
                  SizedBox(height: 20),
                ],
                
                // Additional information section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Phone
                      if (userPhone.isNotEmpty && userPhone != 'Not provided' && userPhone != 'Loading...')
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Expanded(child: Text(userPhone)),
                          ],
                        ),
                      
                      SizedBox(height: 8),
                      
                      // Address
                      if (userAddress.isNotEmpty && userAddress != 'Not provided' && userAddress != 'Loading...')
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Expanded(child: Text(userAddress)),
                          ],
                        ),
                      
                      SizedBox(height: 8),
                      
                      // CNIC
                      if (userCNIC.isNotEmpty && userCNIC != 'Not provided')
                        Row(
                          children: [
                            Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Expanded(child: Text(userCNIC)),
                          ],
                        ),
                      
                      SizedBox(height: 8),
                      
                      
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // donation history section
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Donation History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 10),
                    
                    // history content or empty state
                    if (donationHistory.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.bloodtype_outlined, size: 48, color: Colors.grey[400]),
                            SizedBox(height: 10),
                            Text(
                              'No donation history yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Start your journey by donating blood!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: donationHistory.map((donation) {
                          return DonationHistoryTile(
                            title: donation['type'] ?? 'Blood Donation',
                            subTitle: donation['date'] ?? 'Unknown date',
                            location: donation['location'] ?? '',
                          );
                        }).toList(),
                      ),
                  ],
                ),
                
                SizedBox(height: 40),
                
                // debug button to check Firestore data
                InkWell(
                  onTap: () async {
                    final user = _auth.currentUser;
                    if (user != null) {
                      final doc = await _firestore.collection('User').doc(user.uid).get();
                      print('Firestore data: ${doc.data()}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Document exists: ${doc.exists}\nData: ${doc.data()}'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Debug: Check Firestore Data',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ),
                
                // sign out button
                InkWell(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    
                    // Navigate back to the root (App widget)
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    padding: EdgeInsets.all(14),
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          if (currentIndex == 0) {
            Navigator.pushNamed(context, '/homeScreen');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonationHistoryTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String location;
  
  const DonationHistoryTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.location = '',
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-16, 0),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.bloodtype, size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subTitle, style: TextStyle(color: Colors.red)),
            if (location.isNotEmpty)
              Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}