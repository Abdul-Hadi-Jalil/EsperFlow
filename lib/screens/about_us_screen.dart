// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Owners information list
    final List<Map<String, String>> owners = [
      {
        'name': 'Awais Tahir',
        'position': 'CEO',
        'phone': '03189005624',
        'email': 'L1f21bsds0012@ucp.edu.pk',
        'description': 'Awais is the visionary behind EsperFlow, driving the strategic direction and overall success of our mission to revolutionize blood donation through technology.',
      },
      {
        'name': 'Umar Tariq',
        'position': 'Manager',
        'phone': '03104878731',
        'email': 'l1f21bsds0055@ucp.edu.pk',
        'description': 'Umar oversees daily operations and ensures seamless coordination between donors, recipients, and healthcare partners to maximize our impact.',
      },
    ];

    void launchEmail(String email) async {
      final url = Uri.parse('mailto:$email');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }

    void makeCall(String phone) async {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }

    void copyToClipboard(String text, String type) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type copied to clipboard'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Container(
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
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade600,
                      Colors.red.shade800,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EsperFlow',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Connecting Life, Saving Lives',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Mission Statement
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'At EsperFlow, we are dedicated to creating a centralized platform that bridges the gap between blood donors and those in need. Our mission is to revolutionize the blood donation ecosystem by providing a reliable, efficient, and accessible system that connects willing donors with recipients during critical times. We believe that every life is precious, and by leveraging technology, we aim to eliminate delays in finding compatible blood types, reduce dependency on fragmented systems, and create a community-driven network where help is just a tap away. Together, we are building a future where no one has to suffer due to the unavailability of blood.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              // Team Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Meet Our Team',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'The passionate individuals behind EsperFlow who work tirelessly to make blood donation accessible to everyone.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Owners List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: owners.length,
                      itemBuilder: (context, index) {
                        final owner = owners[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: Colors.red.shade700,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            owner['name']!,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.red.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            owner['position']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  owner['description']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Contact Information
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contact Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Phone Number
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_outlined,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              owner['phone']!,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.call,
                                              color: Colors.red.shade700,
                                            ),
                                            onPressed: () => makeCall(owner['phone']!),
                                            tooltip: 'Call',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.content_copy,
                                              color: Colors.red.shade700,
                                            ),
                                            onPressed: () => copyToClipboard(owner['phone']!, 'Phone number'),
                                            tooltip: 'Copy number',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Email
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              owner['email']!,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.email,
                                              color: Colors.red.shade700,
                                            ),
                                            onPressed: () => launchEmail(owner['email']!),
                                            tooltip: 'Send email',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.content_copy,
                                              color: Colors.red.shade700,
                                            ),
                                            onPressed: () => copyToClipboard(owner['email']!, 'Email'),
                                            tooltip: 'Copy email',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

             
            ],
          ),
        ),
      ),
    );
  }
}