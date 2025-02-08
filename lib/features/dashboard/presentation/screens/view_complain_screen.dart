import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewComplainScreen extends StatelessWidget {
  const ViewComplainScreen({super.key});

  Future<void> _logout(BuildContext context) async {
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

    Navigator.pop(context); // Close the dialog
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()) // Navigate to Login screen
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          "View complaints",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context); // Call logout when logout option is selected
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
