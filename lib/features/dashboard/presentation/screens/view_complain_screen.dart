import 'package:egov_project/features/dashboard/presentation/screens/edit_complaint_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:shimmer/shimmer.dart'; // For shimmer effect

class ViewComplainScreen extends StatefulWidget {
  const ViewComplainScreen({super.key});

  @override
  ViewComplainScreenState createState() => ViewComplainScreenState();
}

class ViewComplainScreenState extends State<ViewComplainScreen> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
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
        Uri.parse("https://egov-backend.vercel.app/api/file/complain"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('complains') && data['complains'] is List) {
          setState(() {
            _complaints = data['complains'];
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
              'Failed to load complaints. Status code: ${response.statusCode}';
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
            'Request timed out. Please check your internet connection.$e';
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
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffB81736),
        title: Text(
          "View Your Complaints",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
          ? _buildShimmerEffect() // Use shimmer effect for loading
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
              : _complaints.isEmpty
                  ? Center(
                      child: Text(
                        'No complaints found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = _complaints[index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${complaint['subject'] ?? 'No Subject'}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  complaint['description'] ?? 'No Description',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      "Category: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      "${complaint['category'] ?? 'Uncategorized'}",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Status: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      "${complaint['status'] ?? 'Unknown'}",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (complaint['image'] != null &&
                                        complaint['image'].isNotEmpty)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageViewScreen(
                                                imageUrl: complaint['image'],
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          side: BorderSide(color: Colors.grey),
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        child: Text(
                                          'View Image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ElevatedButton(
                                      // onPressed: () {},
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditComplaintScreen(
                                                    complaint: complaint),
                                          ),
                                        );

                                        // If the user successfully updated the complaint, refresh the list
                                        if (result == true) {
                                          _fetchComplaints();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        side: BorderSide(color: Colors.red),
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                      ),
                                      child: Text(
                                        'Edit Complaint',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  // Shimmer effect for loading state
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer for subject
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 6),

                  // Shimmer for image placeholder
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// New screen to view the image
class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Color(0xffB81736),
        title: Text(
          'Complaint Image',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text('Failed to load image');
          },
        ),
      ),
    );
  }
}


// import 'package:egov_project/features/dashboard/presentation/screens/edit_complaint_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
// import 'package:shimmer/shimmer.dart'; // For shimmer effect

// class ViewComplainScreen extends StatefulWidget {
//   const ViewComplainScreen({super.key});

//   @override
//   ViewComplainScreenState createState() => ViewComplainScreenState();
// }

// class ViewComplainScreenState extends State<ViewComplainScreen> {
//   List<dynamic> _complaints = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchComplaints();
//   }

//   Future<void> _fetchComplaints() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('accessToken');

//       if (token == null) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Session expired. Please log in again.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse("https://egov-backend.vercel.app/api/file/complain"),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       ).timeout(Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('complains') && data['complains'] is List) {
//           setState(() {
//             _complaints = data['complains'];
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = 'Invalid data format from the server.';
//           });
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage =
//               'Failed to load complaints. Status code: ${response.statusCode}';
//         });
//       }
//     } on http.ClientException catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Network error: ${e.message}';
//       });
//     } on FormatException catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Data parsing error: ${e.message}';
//       });
//     } on Exception catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage =
//             'Request timed out. Please check your internet connection.$e';
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'An unexpected error occurred: $e';
//       });
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 20),
//                 Text("Logging out..."),
//               ],
//             ),
//           );
//         },
//       );

//       await Future.delayed(Duration(seconds: 1));
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('accessToken');

//       if (context.mounted) {
//         Navigator.pop(context);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to logout: $e')),
//         );
//       }
//     }
//   }

//   /// Navigate to Update Status Screen
//   void _navigateToUpdateStatusScreen(Map<String, dynamic> complaint) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditComplaintScreen(complaint: complaint),
//       ),
//     ).then((result) {
//       // Refresh the list if the status was updated
//       if (result == true) {
//         _fetchComplaints();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xffB81736),
//         title: Text(
//           "View Users Complaints",
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(
//               Icons.more_vert,
//               color: Colors.white,
//             ),
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
//                   child: Text('Logout'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? _buildShimmerEffect() // Use shimmer effect for loading
//           : _errorMessage.isNotEmpty
//               ? Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       _errorMessage,
//                       style: TextStyle(fontSize: 16, color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 )
//               : _complaints.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No complaints found.',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: EdgeInsets.all(16),
//                       itemCount: _complaints.length,
//                       itemBuilder: (context, index) {
//                         final complaint = _complaints[index];
//                         return Card(
//                           color: Colors.white,
//                           margin: EdgeInsets.only(bottom: 16),
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "${complaint['subject'] ?? 'No Subject'}",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   complaint['description'] ?? 'No Description',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "Category: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.grey),
//                                     ),
//                                     Text(
//                                       "${complaint['category'] ?? 'Uncategorized'}",
//                                       style: TextStyle(color: Colors.blue),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "Status: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.grey),
//                                     ),
//                                     Text(
//                                       "${complaint['status'] ?? 'Unknown'}",
//                                       style: TextStyle(color: Colors.red),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     if (complaint['image'] != null &&
//                                         complaint['image'].isNotEmpty)
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   ImageViewScreen(
//                                                 imageUrl: complaint['image'],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                           side: BorderSide(color: Colors.grey),
//                                           backgroundColor: Colors.white,
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 0),
//                                         ),
//                                         child: Text(
//                                           'View Image',
//                                           style: TextStyle(color: Colors.grey),
//                                         ),
//                                       ),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         _navigateToUpdateStatusScreen(
//                                             complaint);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8)),
//                                         side: BorderSide(color: Colors.red),
//                                         backgroundColor: Colors.white,
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 10, vertical: 0),
//                                       ),
//                                       child: Text(
//                                         'Manage Complaint',
//                                         style: TextStyle(color: Colors.red),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }

//   // Shimmer effect for loading state
//   Widget _buildShimmerEffect() {
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: 5, // Number of shimmer items
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Card(
//             margin: EdgeInsets.only(bottom: 16),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Shimmer for subject
//                   Container(
//                     width: double.infinity,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),

//                   SizedBox(height: 6),
//                   Container(
//                     width: double.infinity,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   SizedBox(height: 6),

//                   // Shimmer for image placeholder
//                   Container(
//                     width: double.infinity,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // New screen to view the image
// class ImageViewScreen extends StatelessWidget {
//   final String imageUrl;

//   const ImageViewScreen({super.key, required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.white,
//             )),
//         backgroundColor: Color(0xffB81736),
//         title: Text(
//           'Complaint Image',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Text('Failed to load image');
//           },
//         ),
//       ),
//     );
//   }
// }
