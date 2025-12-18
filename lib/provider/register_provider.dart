import 'package:flutter/material.dart';

class RegisterProvider extends ChangeNotifier {
  late String name;
  late String email;
  late String password;
  late String phoneNumber;
  late String bloodGroup;
  late String address;

  void updateRegisterData({
    required String newName,
    required String newEmail,
    required String newPassword,
    required String newPhoneNumber,
    required String newBloodGroup,
    required String newAddress,
  }) async {
    name = newName;
    email = newEmail;
    password = newPassword;
    phoneNumber = newPhoneNumber;
    bloodGroup = newBloodGroup;
    address = newAddress;

    notifyListeners();
  }
}
