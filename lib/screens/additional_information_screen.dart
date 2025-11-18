import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class AdditionalInformationScreen extends StatefulWidget {
  const AdditionalInformationScreen({super.key});

  @override
  State<AdditionalInformationScreen> createState() =>
      _AdditionalInformationScreenState();
}

class _AdditionalInformationScreenState
    extends State<AdditionalInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // last blood donation field
            MyTextField(),

            // CNIC field
            MyTextField(),

            // upload cnic image button
            // TODO: create a button for user to use camera or upload from gallery

            // health history
            Text('Health History'),
            Text(
              'Have you had any diseases or health issues in the past 3 years',
            ),

            // yes/no option
            // TODO to be implemented

            // check boxes for agreement
            // TODO to be implemented

            // back and submit button
            Row(
              children: [
                // back button
                MyCustomButtom(),

                // submit buttom
                MyCustomButtom(),
              ],
            ),

            // footer text
            Text('Your data is secure and used only for donation purposes'),
          ],
        ),
      ),
    );
  }
}
