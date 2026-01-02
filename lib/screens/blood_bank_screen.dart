import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBanksScreen extends StatelessWidget {
  BloodBanksScreen({super.key});

  // List of blood donation organizations with links
  final List<Map<String, dynamic>> bloodOrganizations = [
    {
      'name': 'Pakistan Red Crescent Society',
      'description': 'National blood transfusion service',
      'phone': '0519250404', // Changed: removed dashes
      'website': 'https://www.prcs.org.pk/',
      'icon': Icons.flag_outlined,
      'color': Colors.red,
    },
    {
      'name': 'Fatmid Foundation',
      'description': 'Thalassemia & blood disorder center',
      'phone': '021111123456', // Changed: removed dashes
      'website': 'https://www.fatmid.org/',
      'icon': Icons.medical_services_outlined,
      'color': Colors.green,
    },
    {
      'name': 'Shaukat Khanum Memorial Hospital',
      'description': 'Cancer hospital blood bank',
      'phone': '04235905000', // Changed: removed dashes
      'website': 'https://www.shaukatkhanum.org.pk/',
      'icon': Icons.local_hospital_outlined,
      'color': Colors.blue,
    },
    {
      'name': 'Edhi Foundation',
      'description': 'Emergency blood donation service',
      'phone': '021111111111', // Changed: removed dashes
      'website': 'https://edhi.org/',
      'icon': Icons.emergency_outlined,
      'color': Colors.orange,
    },
    {
      'name': 'Chhipa Welfare Association',
      'description': 'Ambulance & blood donation services',
      'phone': '1020',
      'website': 'https://chhipa.org/',
      'icon': Icons.airline_seat_individual_suite_outlined,
      'color': Colors.purple,
    },
    {
      'name': 'JDC Foundation',
      'description': 'Medical & blood donation services',
      'phone': '021111111112', // Changed: removed dashes
      'website': 'https://www.jdcwelfare.org/',
      'icon': Icons.group_outlined,
      'color': Colors.teal,
    },
    {
      'name': 'Punjab Blood Transfusion Service',
      'description': 'Government blood bank network',
      'phone': '04299200100', // Changed: removed dashes
      'website': 'http://pbs.punjab.gov.pk/',
      'icon': Icons.bloodtype_outlined,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Saylani Welfare Trust',
      'description': 'Free blood bank services',
      'phone': '021111111113', // Changed: removed dashes
      'website': 'https://saylaniwelfare.com/',
      'icon': Icons.volunteer_activism_outlined,
      'color': Colors.indigo,
    },
  ];

  final List<Map<String, String>> quickTips = [
    {
      'tip': 'You can donate blood every 56 days',
      'icon': '🩸',
    },
    {
      'tip': 'Drink plenty of water before donating',
      'icon': '💧',
    },
    {
      'tip': 'Eat iron-rich foods like spinach',
      'icon': '🥬',
    },
    {
      'tip': 'Bring ID when going to donate',
      'icon': '🪪',
    },
  ];

  Future<void> _openWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // This is important
        );
      } else {
        _showErrorSnackBar('Could not launch $url');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _makeCall(String phone) async {
    try {
      // Clean the phone number - remove any non-digit characters
      final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      
      // Check if it's a valid phone number
      if (cleanedPhone.isEmpty) {
        _showErrorSnackBar('Invalid phone number');
        return;
      }

      final uri = Uri.parse('tel:$cleanedPhone');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorSnackBar('Could not make call to $phone');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    // We'll show the snackbar using a global key or context
    // For now, print to console
    print(message);
  }

  Widget _organizationCard(Map<String, dynamic> org, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: org['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: org['color'].withOpacity(0.3)),
                  ),
                  child: Icon(
                    org['icon'] as IconData,
                    color: org['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      Text(
                        org['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Divider(
              color: Colors.red.shade100,
              height: 1,
            ),
            
            const SizedBox(height: 12),
            
            // Contact Information
            Row(
              children: [
                // Phone
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPhoneNumber(org['phone']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Call Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(org['phone']),
                    icon: Icon(
                      Icons.call,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Website Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openWebsite(org['website']),
                    icon: Icon(
                      Icons.language,
                      size: 18,
                      color: Colors.red.shade700,
                    ),
                    label: Text(
                      'Website',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    // Format phone number for display
    if (phone.length >= 10) {
      if (phone.startsWith('0')) {
        return '+92 ${phone.substring(1, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
      } else if (phone.startsWith('92')) {
        return '+${phone.substring(0, 2)} ${phone.substring(2, 5)} ${phone.substring(5, 8)} ${phone.substring(8)}';
      } else if (phone.length == 4) {
        return phone; // For short numbers like 1020
      }
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Banks & Organizations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Blood Urgently?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            Text(
                              'If EsperFlow cannot help, contact these organizations directly',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
               
                // Organizations Header
                Row(
                  children: [
                    Icon(
                      Icons.bloodtype_outlined,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Blood Donation Organizations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                
                Text(
                  'These organizations can help with blood donation and transfusion services',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Organizations List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bloodOrganizations.length,
                  itemBuilder: (context, index) {
                    return _organizationCard(bloodOrganizations[index], context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Additional Help Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Need More Help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'If you still cannot find blood, try:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.red.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Contact nearby hospitals directly',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.red.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Check social media blood donation groups',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.red.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ask friends and family for donors',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}