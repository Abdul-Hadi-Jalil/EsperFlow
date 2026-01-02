import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifiedHospitalsScreen extends StatelessWidget {
  const VerifiedHospitalsScreen({super.key});

  // List of verified hospitals from your Excel data
  final List<Map<String, String>> hospitals = const [
    {
      'name': 'Mayo Hospital',
      'address': 'Nila Gumbad, Lahore',
      'phone': '042-99211101',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Mayo+Hospital+Lahore',
      'type': 'Public',
      'note': 'Major government teaching hospital',
    },
    {
      'name': 'Services Hospital',
      'address': 'Jail Road, Lahore',
      'phone': '042-99203402',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Services+Hospital+Lahore',
      'type': 'Public',
      'note': 'Teaching hospital',
    },
    {
      'name': 'Lahore General Hospital',
      'address': 'Ferozepur Road, Lahore',
      'phone': '042-99268801',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Lahore+General+Hospital+Lahore',
      'type': 'Public',
      'note': 'Emergency & trauma center',
    },
    {
      'name': 'Jinnah Hospital',
      'address': 'Usmani Road, Lahore',
      'phone': '042-99231480',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Jinnah+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'Teaching & tertiary care',
    },
    {
      'name': 'Sheikh Zayed Hospital',
      'address': 'New Muslim Town, Lahore',
      'phone': '042-35865731',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Sheikh+Zayed+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'Medical complex',
    },
    {
      'name': 'Shaukat Khanum Memorial Hospital',
      'address': 'Johar Town, Lahore',
      'phone': '042-35905000',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Shaukat+Khanum+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'Cancer hospital',
    },
    {
      'name': 'Fatima Memorial Hospital',
      'address': 'Shadman, Lahore',
      'phone': '042-111555600',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Fatima+Memorial+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'Multi-specialty',
    },
    {
      'name': 'Doctors Hospital',
      'address': 'Canal Road, Lahore',
      'phone': '042-111223377',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Doctors+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'Multi-specialty',
    },
    {
      'name': 'National Hospital DHA',
      'address': 'DHA Phase 1, Lahore',
      'phone': '042-111171819',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=National+Hospital+DHA+Lahore+Lahore',
      'type': 'Private',
      'note': 'Multi-specialty',
    },
    {
      'name': 'Ittefaq Hospital',
      'address': 'Model Town, Lahore',
      'phone': '042-35881981',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Ittefaq+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'Trust hospital',
    },
    {
      'name': 'Gulab Devi Hospital',
      'address': 'Ferozepur Road, Lahore',
      'phone': '042-99230247',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Gulab+Devi+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'Teaching hospital',
    },
    {
      'name': 'Punjab Institute of Cardiology',
      'address': 'Jail Road, Lahore',
      'phone': '042-99203051',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Punjab+Institute+of+Cardiology+Lahore+Lahore',
      'type': 'Public',
      'note': 'Cardiac hospital',
    },
    {
      'name': 'Children Hospital Lahore',
      'address': 'Ferozepur Road, Lahore',
      'phone': '042-99230881',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Children+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'Pediatric hospital',
    },
    {
      'name': 'Lady Aitchison Hospital',
      'address': 'Mall Road, Lahore',
      'phone': '042-99203303',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Lady+Aitchison+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'Gynecology & maternity',
    },
    {
      'name': 'WAPDA Hospital',
      'address': 'WAPDA Town, Lahore',
      'phone': '042-35161111',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=WAPDA+Hospital+Lahore+Lahore',
      'type': 'Public',
      'note': 'General hospital',
    },
    {
      'name': 'CMH Lahore',
      'address': 'Abdul Rehman Road, Lahore Cantt',
      'phone': '042-36605550',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=CMH+Lahore+Lahore',
      'type': 'Military',
      'note': 'Combined Military Hospital',
    },
    {
      'name': 'Ibn-e-Sina Hospital',
      'address': 'Johar Town, Lahore',
      'phone': '042-35302701',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Ibn+e+Sina+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'General hospital',
    },
    {
      'name': 'Hameed Latif Hospital',
      'address': 'Garden Town, Lahore',
      'phone': '042-35761999',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Hameed+Latif+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'Multi-specialty',
    },
    {
      'name': 'Evercare Hospital Lahore',
      'address': 'DHA Phase 8, Lahore',
      'phone': '042-111223333',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Evercare+Hospital+Lahore+Lahore',
      'type': 'Private',
      'note': 'International standard',
    },
    {
      'name': 'Akram Medical Complex',
      'address': 'DHA Phase 6, Lahore',
      'phone': '042-35761999',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Akram+Medical+Complex+Lahore+Lahore',
      'type': 'Private',
      'note': 'General hospital',
    },
    {
      'name': 'Iqra Medical Complex',
      'address': 'Johar Town, Lahore',
      'phone': '042-35171111',
      'city': 'Lahore',
      'province': 'Punjab',
      'mapsLink': 'https://www.google.com/maps/search/?api=1&query=Iqra+Medical+Complex+Lahore+Lahore',
      'type': 'Private',
      'note': 'General hospital',
    },
  ];

  void _callHospital(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openMaps(String mapsLink) async {
    final url = Uri.parse(mapsLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _hospitalTypeBadge(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'public':
        color = Colors.green;
        break;
      case 'private':
        color = Colors.blue;
        break;
      case 'military':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verified Hospitals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
        child: Column(
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.red.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Hospitals in Lahore',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        Text(
                          'All hospitals are verified by EsperFlow for blood donation services',
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search hospitals...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        onChanged: (value) {
                          // You can add search functionality here
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hospital List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = hospitals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  hospital['name']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _hospitalTypeBadge(hospital['type']!),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Address
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.red.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  hospital['address']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Note
                          Text(
                            hospital['note']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Divider(
                            color: Colors.red.shade100,
                            height: 1,
                          ),

                          const SizedBox(height: 12),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Call Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _callHospital(hospital['phone']!),
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
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Directions Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openMaps(hospital['mapsLink']!),
                                  icon: Icon(
                                    Icons.directions,
                                    size: 18,
                                    color: Colors.red.shade700,
                                  ),
                                  label: Text(
                                    'Directions',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red.shade700),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Phone Display
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade100),
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
                                    Text(
                                      hospital['phone']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Note
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${hospitals.length} verified hospitals in Lahore',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
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
    );
  }
}