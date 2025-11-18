import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class BloodRequestScreen extends StatelessWidget {
  const BloodRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blood Request'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // full name field
            MyTextField(hintText: "Full Name"),

            // phone number field
            MyTextField(hintText: 'Phone Number'),

            // drop down menu for blood group selection
            // TODO: will be implemented

            // required blood quantity
            // TODO: same drop down as blood group

            // text for donor
            Text('Each donor can safely donate upto 400ml'),

            // location field
            MyTextField(hintText: "Location"),

            // hospital or cnic field
            MyTextField(hintText: "Hospital or CNIC"),

            // additional notes
            MyTextField(hintText: "Additional Notes (Optional)"),

            // submit button
            MyCustomButtom(
              backgroundColor: Colors.red,
              text: "Submit Request",
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
