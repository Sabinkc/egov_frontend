import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Create a logger instance
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Function to fetch data from the API with logger integrated for better debugging
  Future<void> _fetchData() async {
    final url = 'https://egov-backend.vercel.app/api/govt/gov-web-data';

    try {
      logger.i('Fetching data from the API...'); // Info log
      final response = await http.get(Uri.parse(url));

      // Log response status and body
      logger
          .d('Response status: ${response.statusCode}'); // Debug log for status
      logger.d('Response body: ${response.body}'); // Debug log for body

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Log the decoded data
        logger.i('Decoded data: $data'); // Info log for data

        // Check if the data is in the expected format
        if (data.containsKey('data') && data['data'] is List) {
          setState(() {
            _data = data['data']; // Extract the list
            _isLoading = false;
            logger.i('Data loaded successfully.');
          });
        } else {
          setState(() {
            _errorMessage =
                'Data format is not as expected. Missing "data" key or the value is not a list.';
            _isLoading = false;
            logger
                .e('Error: Data format issue. Missing or invalid "data" key.');
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data. Status Code: ${response.statusCode}';
          _isLoading = false;
          logger.e(
              'Error: Failed to load data. Status code: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
        logger.e('Error occurred: $e'); // Error log for exceptions
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
              ),
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

    if (context.mounted) {
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
      appBar: AppBar(
        backgroundColor: Color(0xffB81736),
        title: Text(
          "Government Agencies",
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading spinner
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // Error message
              : ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    var item = _data[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: Image.network(
                          item['image_url'] ?? 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, size: 50);
                          },
                        ),
                        title: Text(
                          item['name'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              item['description'] ?? 'No Description',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Address: ${item['address'] ?? 'No Address'}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                // Open the URL in the browser
                                // launchURL(item['website_url'] ?? '');
                                final Uri url =
                                    Uri.parse(item['website_url']);

                                Future<void> _launchUrl() async {
                                  if (!await launchUrl(url)) {
                                    // Show a Snackbar if URL can't be launched
                                 if(context.mounted){
                                     ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Could not launch $url'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                 }
                                  }
                                }

                                _launchUrl();
                              },
                              child: Text(
                                item['website_url'] ?? 'No URL',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
