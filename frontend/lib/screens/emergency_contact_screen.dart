import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  // List of emergency contacts relevant for blood donation/medical emergencies
  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'Rescue 1122',
      'number': '1122',
      'description': 'Emergency Ambulance & Medical Rescue',
      'icon': Icons.medical_services_outlined,
      'isCritical': true,
    },
    {
      'name': 'Edhi Ambulance',
      'number': '115',
      'description': '24/7 Emergency Ambulance Service',
      'icon': Icons.airline_seat_individual_suite_outlined,
      'isCritical': true,
    },
    {
      'name': 'Police Help line',
      'number': '15',
      'description': 'Emergency Police number',
      'icon': Icons.emergency_outlined,
      'isCritical': true,
    },
    {
      'name': 'Jinnah Hospital',
      'number': '021-99201300',
      'description': 'Karachi - Emergency & Blood Bank',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'name': 'Punjab Blood Transfusion',
      'number': '042-99200100',
      'description': 'Lahore - Blood Bank Services',
      'icon': Icons.bloodtype_outlined,
    },
    {
      'name': 'Shaukat Khanum Hospital',
      'number': '042-35905000',
      'description': 'Lahore - Cancer & Blood Disorders',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'name': 'Blood Donor Helpline',
      'number': '1134',
      'description': 'National Blood Donor Service',
      'icon': Icons.phone_in_talk_outlined,
    },
    {
      'name': 'Medical Emergency',
      'number': '1150',
      'description': 'General Medical Emergency',
      'icon': Icons.emergency_outlined,
    },
  ];

  void _copyToClipboard(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Number copied to clipboard'),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> contact) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: contact['isCritical'] == true
              ? Colors.red.shade400
              : Colors.red.shade200,
          width: contact['isCritical'] == true ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: contact['isCritical'] == true
                ? Colors.red.shade100
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: contact['isCritical'] == true
                  ? Colors.red.shade300
                  : Colors.red.shade100,
            ),
          ),
          child: Icon(
            contact['icon'] as IconData,
            color: contact['isCritical'] == true
                ? Colors.red.shade700
                : Colors.red.shade600,
            size: 28,
          ),
        ),
        title: Text(
          contact['name'],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.red.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact['description'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              contact['number'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.content_copy,
            color: Colors.red.shade600,
            size: 28,
          ),
          onPressed: () => _copyToClipboard(contact['number']),
          tooltip: 'Copy number',
        ),
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _copyToClipboard(contact['number']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
              Colors.red.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Contacts List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medical Emergency Contacts Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'MEDICAL EMERGENCY CONTACTS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Instructions
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            color: Colors.red.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any contact card or the copy icon to copy the number to clipboard',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contacts List
                    ...emergencyContacts.map((contact) => _buildEmergencyCard(contact)),

                    // Important Note
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'For blood donation inquiries or emergencies, always verify the blood type requirements before calling.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}