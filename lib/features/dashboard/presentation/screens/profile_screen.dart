import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse("https://egov-backend.vercel.app/api/users/profile"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10)); // Add timeout to prevent hanging

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('user') && data['user'] is Map) {
          setState(() {
            _userProfile = data['user'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid data format from the server.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load profile. Status code: ${response.statusCode}';
        });
      }
    } on http.ClientException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: ${e.message}';
      });
    } on FormatException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data parsing error: ${e.message}';
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Request timed out. Please check your internet connection. $e';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
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

      await Future.delayed(Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffB81736),
        title: Text(
          "Profile",
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
                _logout(context);
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _userProfile == null
                  ? Center(
                      child: Text(
                        'No profile data found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xffB81736),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildProfileItem(
                              "Username", _userProfile!['username']),
                          _buildProfileItem("Email", _userProfile!['email']),
                          _buildProfileItem("Role", _userProfile!['role']),
                          _buildProfileItem(
                              "Joined On", _userProfile!['createdAt']),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(height: 20, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
