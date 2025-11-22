// used in home screen

import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Function()? onTap;

  const MenuItemCard({
    super.key,
    required this.iconData,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 25),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 28, color: Colors.black),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
