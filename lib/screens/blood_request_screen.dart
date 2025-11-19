import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  String? selectedBloodGroup;
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blood Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 24,
            children: [
              // full name field
              MyTextField(hintText: "Full Name"),

              // phone number field
              MyTextField(hintText: 'Phone Number'),

              // drop down menu for blood group selection
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodGroup,
                    hint: Text(
                      "Select Blood Group",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: bloodGroups.map((group) {
                      return DropdownMenuItem(value: group, child: Text(group));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value!;
                      });
                    },
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),

              // drop down menu for required blood quantity
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodGroup,
                    hint: Text(
                      "Required Blood Quatity",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: bloodGroups.map((group) {
                      return DropdownMenuItem(value: group, child: Text(group));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value!;
                      });
                    },
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),

              // text for donor
              Transform.translate(
                offset: Offset(-35, -10),
                child: Text(
                  'Each donor can safely donate upto 400ml',
                  style: TextStyle(color: Colors.red),
                ),
              ),

              // location field
              MyTextField(hintText: "Location"),

              // hospital or cnic field
              MyTextField(hintText: "Hospital or CNIC"),

              // additional notes
              MyTextField(hintText: "Additional Notes (Optional)"),

              // submit button
              MyCustomButtom(
                backgroundColor: Color(0xFFE31A1A),
                text: "Submit Request",
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
