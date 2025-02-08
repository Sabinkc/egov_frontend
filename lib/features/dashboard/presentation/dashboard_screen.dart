import 'package:egov_project/features/dashboard/presentation/screens/add_complaint_screen.dart';
import 'package:egov_project/features/dashboard/presentation/screens/home_screen.dart';
import 'package:egov_project/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:egov_project/features/dashboard/presentation/screens/view_complain_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool isLoggingOut = false; // To track loading state
  final List<Widget> _pages = [
    HomeScreen(),
    AddComplaintScreen(),
    ViewComplainScreen(),
    ProfileScreen(),
  ];

  Future<void> logout(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );

    // Simulate a logout delay (1 second)
    await Future.delayed(Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); // Remove token

if(context.mounted){
      Navigator.pop(context); // Close the dialog
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()) // Navigate to Login screen
        );
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggingOut
          ? Center(
              child:
                  CircularProgressIndicator()) // Show progress indicator during logout
          : _pages[_selectedIndex],
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: Colors.white,
        waterDropColor: Color(0xffB81736),
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        barItems: [
          BarItem(
            filledIcon: Icons.home,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.report,
            outlinedIcon: Icons.report_outlined,
          ),
          BarItem(
            filledIcon: Icons.visibility,
            outlinedIcon: Icons.visibility_outlined,
          ),
           BarItem(
            filledIcon: Icons.person,
            outlinedIcon: Icons.person_outlined,
          ),
        ],
      ),
    );
  }
}
