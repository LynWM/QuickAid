import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: must_be_immutable
class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;

  MyBottomNavBar({
    super.key,
    required this.onTabChange,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GNav(
        color: Color(0xFF890000),
        activeColor: Colors.black,
        tabActiveBorder: Border.all(color: Colors.white),
        tabBackgroundColor: Colors.grey,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        tabBorderRadius: 16,
        onTabChange: (value) => onTabChange!(value),

        tabs: [
          GButton(
            icon: Icons.medical_services_rounded,
            text: 'Guides',
            ),
            GButton(
            icon: Icons.location_on,
            text: 'Map',
            ),
            GButton(
            icon: Icons.phone,
            text: 'Hotlines',
            ),
        ],
        ),
    );
  }
}
