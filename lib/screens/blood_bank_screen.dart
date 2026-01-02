import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBanksScreen extends StatelessWidget {
   BloodBanksScreen({super.key});

  // List of blood donation organizations with links
  final List<Map<String, dynamic>> bloodOrganizations = [
    {
      'name': 'Pakistan Red Crescent Society',
      'description': 'National blood transfusion service',
      'phone': '051-9250404',
      'website': 'https://www.prcs.org.pk/',
      'icon': Icons.flag_outlined,
      'color': Colors.red,
    },
    {
      'name': 'Fatmid Foundation',
      'description': 'Thalassemia & blood disorder center',
      'phone': '021-111-123-456',
      'website': 'https://www.fatmid.org/',
      'icon': Icons.medical_services_outlined,
      'color': Colors.green,
    },
    {
      'name': 'Shaukat Khanum Memorial Hospital',
      'description': 'Cancer hospital blood bank',
      'phone': '042-35905000',
      'website': 'https://www.shaukatkhanum.org.pk/',
      'icon': Icons.local_hospital_outlined,
      'color': Colors.blue,
    },
    {
      'name': 'Edhi Foundation',
      'description': 'Emergency blood donation service',
      'phone': '021-111-111-111',
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
      'phone': '021-111-111-112',
      'website': 'https://www.jdcwelfare.org/',
      'icon': Icons.group_outlined,
      'color': Colors.teal,
    },
    {
      'name': 'Punjab Blood Transfusion Service',
      'description': 'Government blood bank network',
      'phone': '042-99200100',
      'website': 'http://pbs.punjab.gov.pk/',
      'icon': Icons.bloodtype_outlined,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Saylani Welfare Trust',
      'description': 'Free blood bank services',
      'phone': '021-111-111-113',
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

  void _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _organizationCard(Map<String, dynamic> org) {
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
                          org['phone'],
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
                
                // Donation Tips
                Text(
                  'Quick Blood Donation Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3,
                  children: quickTips.map((tip) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade50,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              tip['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tip['tip']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
                    return _organizationCard(bloodOrganizations[index]);
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