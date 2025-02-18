import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For using SVG images

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Future<void> _launchUrl(Uri url, BuildContext context) async {
  //   if (!await launchUrl(url)) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Could not launch $url'),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   }
  // }

  
Future<void> _launchUrl(Uri url, BuildContext context) async {
  try {
    // Validate the URL before launching
    if (url.toString().isEmpty || !url.toString().startsWith('http')) {
      throw 'Invalid URL';
    }

    // Attempt to launch the URL
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

  Future<void> _fetchData() async {
    final url = 'https://egov-backend.vercel.app/api/govt/gov-web-data';

    try {
      logger.i('Fetching data from the API...');
      final response = await http.get(Uri.parse(url));

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        logger.i('Decoded data: $data');

        if (data.containsKey('data') && data['data'] is List) {
          setState(() {
            _data = data['data'];
            _isLoading = false;
            logger.i('Data loaded successfully.');
          });
        } else {
          setState(() {
            _errorMessage =
                'Data format is not as expected. Missing "data" key or the value is not a list.';
            _isLoading = false;
            logger.e('Error: Data format issue.');
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data. Status Code: ${response.statusCode}';
          _isLoading = false;
          logger.e('Error: Failed to load data.');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
        logger.e('Error occurred: $e');
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 3),
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
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffB81736),
        title: Text(
          "Nepal Government Agencies",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.grey,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
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
                  child:
                      Text('Logout', style: TextStyle(color: Colors.black87)),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/error.svg', // Add an error SVG image
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 20),
                        Text(
                          _errorMessage,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffB81736),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _data.length,
                  padding: EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    var item = _data[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          final Uri url = Uri.parse(item['website_url']);
                          _launchUrl(url, context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  item['image_url'] ??
                                      'https://via.placeholder.com/50',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(Icons.error, size: 30),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'No Title',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      item['description'] ?? 'No Description',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 16, color: Colors.redAccent),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            item['address'] ?? 'No Address',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.link,
                                            size: 16, color: Colors.blue),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            item['website_url'] ?? 'No URL',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 8, // Number of skeleton items
      padding: EdgeInsets.all(12),
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:logger/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart'; // For using SVG images

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   List<dynamic> _data = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   var logger = Logger();

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

// Future<void> _launchUrl(Uri url, BuildContext context) async {
//   try {
//     // Validate the URL before launching
//     if (url.toString().isEmpty || !url.toString().startsWith('http')) {
//       throw 'Invalid URL';
//     }

//     // Attempt to launch the URL
//     if (!await launchUrl(url)) {
//       throw 'Could not launch $url';
//     }
//   } catch (e) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

//   Future<void> _fetchData() async {
//     final url = 'https://egov-backend.vercel.app/api/govt/gov-web-data';

//     try {
//       logger.i('Fetching data from the API...');
//       final response = await http.get(Uri.parse(url));

//       logger.d('Response status: ${response.statusCode}');
//       logger.d('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         logger.i('Decoded data: $data');

//         if (data.containsKey('data') && data['data'] is List) {
//           setState(() {
//             _data = data['data'];
//             _isLoading = false;
//             logger.i('Data loaded successfully.');
//           });
//         } else {
//           setState(() {
//             _errorMessage =
//                 'Data format is not as expected. Missing "data" key or the value is not a list.';
//             _isLoading = false;
//             logger.e('Error: Data format issue.');
//           });
//         }
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to load data. Status Code: ${response.statusCode}';
//           _isLoading = false;
//           logger.e('Error: Failed to load data.');
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _isLoading = false;
//         logger.e('Error occurred: $e');
//       });
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(strokeWidth: 3),
//               SizedBox(width: 20),
//               Text("Logging out..."),
//             ],
//           ),
//         );
//       },
//     );

//     await Future.delayed(Duration(seconds: 1));

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('accessToken');

//     if (context.mounted) {
//       Navigator.pop(context);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => LoginScreen()));
//     }
//   }

// Future<void> _addGovernmentData(String name, String description, String address, String imageUrl, String websiteUrl) async {
//   final url = 'https://egov-backend.vercel.app/api/govt/gov-web-data';

//   final Map<String, String> data = {
//     'name': name,
//     'description': description,
//     'address': address,
//     'image_url': imageUrl,
//     'website_url': websiteUrl,
//   };

//   try {
//     // Fetch token from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('accessToken');

//     if (token == null) {
//       logger.w("No token found. Redirecting to login.");
//       // Redirect to login if no token found
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Session expired. Please log in again.')),
//         );
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => LoginScreen()));
//       }
//       return;
//     }

//     logger.i("Sending POST request to: $url");
//     logger.i("Request Body: ${json.encode(data)}");
//     logger.i("Using token: $token");

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",  // Attach token in the header
//       },
//       body: json.encode(data),
//     );

//     logger.i("Response Status Code: ${response.statusCode}");
//     logger.i("Response Body: ${response.body}");

//     if (response.statusCode == 201) {
//       Navigator.pop(context); // Close dialog on success
//       _fetchData(); // Refresh data
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Data added successfully!'), backgroundColor: Colors.green),
//       );
//     } else {
//       logger.e("Failed to add data. Status Code: ${response.statusCode}, Response: ${response.body}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add data'), backgroundColor: Colors.red),
//       );
//     }
//   } catch (e, stackTrace) {
//     logger.e("Error occurred: $e", error: e, stackTrace: stackTrace);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//     );
//   }
// }
    
//   void _showAddDataDialog() {

//     final TextEditingController nameController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     final TextEditingController addressController = TextEditingController();
//     final TextEditingController imageUrlController = TextEditingController();
//     final TextEditingController websiteUrlController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Government Data'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
//                 TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
//                 TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
//                 TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
//                 TextField(controller: websiteUrlController, decoration: InputDecoration(labelText: 'Website URL')),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//             ElevatedButton(
//               onPressed: () {
             
//                 _addGovernmentData(
//                   nameController.text,
//                   descriptionController.text,
//                   addressController.text,
//                   imageUrlController.text,
//                   websiteUrlController.text,
//                 );
             
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditDataDialog(Map<String, dynamic> item) {
//   final TextEditingController nameController = TextEditingController(text: item['name']);
//   final TextEditingController descriptionController = TextEditingController(text: item['description']);
//   final TextEditingController addressController = TextEditingController(text: item['address']);
//   final TextEditingController imageUrlController = TextEditingController(text: item['image_url']);
//   final TextEditingController websiteUrlController = TextEditingController(text: item['website_url']);

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Edit Government Data'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
//               TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
//               TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
//               TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
//               TextField(controller: websiteUrlController, decoration: InputDecoration(labelText: 'Website URL')),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               _updateGovernmentData(
//                 item['_id'], // Assuming the ID is stored in '_id'
//                 nameController.text,
//                 descriptionController.text,
//                 addressController.text,
//                 imageUrlController.text,
//                 websiteUrlController.text,
//               );
//             },
//             child: Text('Update'),
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<void> _updateGovernmentData(String id, String name, String description, String address, String imageUrl, String websiteUrl) async {
//   final url = 'https://egov-backend.vercel.app/api/govt/gov-web-data/$id';

//   final Map<String, String> data = {
//     'name': name,
//     'description': description,
//     'address': address,
//     'image_url': imageUrl,
//     'website_url': websiteUrl,
//   };

//   try {
//     // Fetch token from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('accessToken');

//     if (token == null) {
//       logger.w("No token found. Redirecting to login.");
//       // Redirect to login if no token found
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Session expired. Please log in again.')),
//         );
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => LoginScreen()));
//       }
//       return;
//     }

//     logger.i("Sending PATCH request to: $url");
//     logger.i("Request Body: ${json.encode(data)}");
//     logger.i("Using token: $token");

//     final response = await http.patch(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",  // Attach token in the header
//       },
//       body: json.encode(data),
//     );

//     logger.i("Response Status Code: ${response.statusCode}");
//     logger.i("Response Body: ${response.body}");

//     if (response.statusCode == 200) {
//       Navigator.pop(context); // Close dialog on success
//       _fetchData(); // Refresh data
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Data updated successfully!'), backgroundColor: Colors.green),
//       );
//     } else {
//       logger.e("Failed to update data. Status Code: ${response.statusCode}, Response: ${response.body}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update data'), backgroundColor: Colors.red),
//       );
//     }
//   } catch (e, stackTrace) {
//     logger.e("Error occurred: $e", error: e, stackTrace: stackTrace);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xffB81736),
//         title: Text(
//           "Nepal Government Agencies",
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 10,
//         shadowColor: Colors.grey,
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, color: Colors.white),
//             color: Colors.white,
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _logout(context);
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem<String>(
//                   value: 'logout',
//                   child:
//                       Text('Logout', style: TextStyle(color: Colors.black87)),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xffB81736),
//         onPressed: () {
//           _showAddDataDialog();
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       body: _isLoading
//           ? _buildLoadingSkeleton()
//           : _errorMessage.isNotEmpty
//               ? Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset(
//                           'assets/error.svg', // Add an error SVG image
//                           width: 100,
//                           height: 100,
//                         ),
//                         SizedBox(height: 20),
//                         Text(
//                           _errorMessage,
//                           style: TextStyle(fontSize: 16, color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: _fetchData,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xffB81736),
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 30, vertical: 15),
//                           ),
//                           child: Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : ListView.builder(
//   itemCount: _data.length,
//   padding: EdgeInsets.all(12),
//   itemBuilder: (context, index) {
//     var item = _data[index];
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: InkWell(
//         onTap: () {
//           final Uri url = Uri.parse(item['website_url']);
//           _launchUrl(url, context);
//         },
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(50),
//                 child: Image.network(
//                   item['image_url'] ?? 'https://via.placeholder.com/50',
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.grey[300],
//                       child: Icon(Icons.error, size: 30),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item['name'] ?? 'No Title',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       item['description'] ?? 'No Description',
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on, size: 16, color: Colors.redAccent),
//                         SizedBox(width: 5),
//                         Expanded(
//                           child: Text(
//                             item['address'] ?? 'No Address',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Icon(Icons.link, size: 16, color: Colors.blue),
//                         SizedBox(width: 5),
//                         Expanded(
//                           child: Text(
//                             item['website_url'] ?? 'No URL',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.blue),
//                 onPressed: () {
//                   _showEditDataDialog(item);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   },
// )
//     );
//   }

//   Widget _buildLoadingSkeleton() {
//     return ListView.builder(
//       itemCount: 8, // Number of skeleton items
//       padding: EdgeInsets.all(12),
//       itemBuilder: (context, index) {
//         return Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: EdgeInsets.symmetric(vertical: 8),
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.grey[300],
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 20,
//                         color: Colors.grey[300],
//                       ),
//                       SizedBox(height: 5),
//                       Container(
//                         width: double.infinity,
//                         height: 15,
//                         color: Colors.grey[300],
//                       ),
//                       SizedBox(height: 5),
//                       Container(
//                         width: double.infinity,
//                         height: 15,
//                         color: Colors.grey[300],
//                       ),
//                       SizedBox(height: 5),
//                       Container(
//                         width: double.infinity,
//                         height: 15,
//                         color: Colors.grey[300],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
