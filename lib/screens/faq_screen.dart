import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // logo and text
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // TODO: Add your logo here
                  Icon(Icons.help_outline, size: 60, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Question/Answer section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  // seven qa
                  QATile(
                    question: "Who can donate blood in Pakistan?",
                    answer:
                        "Anyone aged between 18 to 60 years, weighing at least 50 kg, and in good health can donate blood.",
                  ),
                  QATile(
                    question: "How often can I donate blood?",
                    answer:
                        "You can safely donate every 3 to 4 months for men and 4 to 6 months for women.",
                  ),
                  QATile(
                    question: "How much blood is taken during donation?",
                    answer:
                        "Usually 350 to 450 ml (less than one pint) — your body replaces it naturally within a few weeks.",
                  ),
                  QATile(
                    question: "Is donating blood safe?",
                    answer:
                        "Yes. All blood donation equipment used is sterile and disposable, ensuring 100% safety.",
                  ),
                  QATile(
                    question: "How long does a blood donation take?",
                    answer:
                        "The entire process takes about 20 to 30 minutes, including registration and post-donation rest.",
                  ),
                  QATile(
                    question: "Can I donate if I'm taking medication?",
                    answer:
                        "Some medicines are fine, but consult the donation center's medical staff first.",
                  ),
                  QATile(
                    question: "Does ESPERFLOW charge for donations?",
                    answer:
                        "No, donating blood through ESPERFLOW is completely free, we only...",
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

class QATile extends StatelessWidget {
  final String question;
  final String answer;

  const QATile({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Q: ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Answer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
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
}
