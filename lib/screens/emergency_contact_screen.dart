import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'description': 'Emergency Ambulance & Blood Bank',
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
      'name': 'Aga Khan Hospital',
      'number': '021-111-911-911',
      'description': 'Karachi - Emergency & Blood Transfusion',
      'icon': Icons.medical_information_outlined,
    },
    {
      'name': 'PIMS Hospital',
      'number': '051-9261170',
      'description': 'Islamabad - Emergency Services',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'name': 'Fatmid Foundation',
      'number': '021-111-123-456',
      'description': 'Thalassemia & Blood Disorder Center',
      'icon': Icons.bloodtype_outlined,
    },
    {
      'name': 'Punjab Blood Transfusion',
      'number': '042-99200100',
      'description': 'Lahore - Blood Bank Services',
      'icon': Icons.bloodtype_outlined,
    },
    {
      'name': 'SIUT Karachi',
      'number': '021-99215751',
      'description': 'Organ Transplant & Dialysis Center',
      'icon': Icons.healing_outlined,
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
    {
      'name': 'Thalassemia Center',
      'number': '021-34520101',
      'description': 'Karachi Thalassemia Center',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'name': 'Hematology Emergency',
      'number': '021-99261258',
      'description': 'Blood Disorder Emergencies',
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Red Crescent Society',
      'number': '051-9250404',
      'description': 'Emergency Blood & Medical Services',
      'icon': Icons.medical_services_outlined,
    },
  ];

  final List<Map<String, dynamic>> bloodBanks = [
    {
      'name': 'Punjab Blood Transfusion Service',
      'number': '042-99200100',
      'city': 'Lahore',
    },
    {
      'name': 'Sindh Blood Transfusion Authority',
      'number': '021-99261300',
      'city': 'Karachi',
    },
    {
      'name': 'KPK Blood Bank',
      'number': '091-9210333',
      'city': 'Peshawar',
    },
    {
      'name': 'Balochistan Blood Bank',
      'number': '081-9202184',
      'city': 'Quetta',
    },
  ];

  void _callNumber(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch dialer: $number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: Colors.red.shade600,
                  size: 22,
                ),
                onPressed: () => _copyToClipboard(contact['number']),
                tooltip: 'Copy number',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callNumber(contact['number']),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Medical Contacts',
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
            // Emergency Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade800,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emergency_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BLOOD EMERGENCY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'For immediate blood requirements or medical emergencies',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: GestureDetector(
                                onTap: () => _callNumber('1122'),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Colors.red.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DIAL 1122',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: GestureDetector(
                                onTap: () => _callNumber('115'),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.airline_seat_individual_suite,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DIAL 115',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callNumber('1122'),
                      icon: const Icon(Icons.emergency),
                      label: const Text('Rescue 1122'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callNumber('115'),
                      icon: const Icon(Icons.airline_seat_individual_suite),
                      label: const Text('Edhi Ambulance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contacts List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medical Emergency Contacts
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

                    ...emergencyContacts.map((contact) => _buildEmergencyCard(contact)),

                    // Blood Bank Section
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bloodtype,
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'MAJOR BLOOD BANKS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...bloodBanks.map((bank) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bank['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        bank['city'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.call,
                                        color: Colors.red.shade700,
                                      ),
                                      onPressed: () => _callNumber(bank['number']),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      bank['number'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),

                    // Important Note
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
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