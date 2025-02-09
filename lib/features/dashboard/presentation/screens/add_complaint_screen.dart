// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';

// class AddComplaintScreen extends StatefulWidget {
//   const AddComplaintScreen({super.key});

//   @override
//   AddComplaintScreenState createState() => AddComplaintScreenState();
// }

// class AddComplaintScreenState extends State<AddComplaintScreen> {
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _categoryController = TextEditingController();
//   File? _selectedMedia;
//   bool _isSubmitting = false;
//   String _apiResponse = ""; // Stores API response message

//   final Logger _logger = Logger();
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickMedia(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);

//       if (pickedFile != null) {
//         // Check the file extension
//         String fileExtension = pickedFile.path.split('.').last.toLowerCase();
//         _logger.d("Selected file extension: $fileExtension");

//         if (fileExtension != 'jpg' &&
//             fileExtension != 'jpeg' &&
//             fileExtension != 'png') {
//           _logger.w("Unsupported file format: $fileExtension");
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Only JPG, JPEG, and PNG formats are allowed.')),
//           );
//           return;
//         }

//         setState(() {
//           _selectedMedia = File(pickedFile.path);
//         });
//         _logger.i("Media selected: ${_selectedMedia!.path}");
//       } else {
//         _logger.w("No media selected.");
//       }
//     } catch (e) {
//       _logger.e("Error picking media: $e");
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick media: $e')),
//       );
//     }
//   }

//   Future<void> _submitComplaint() async {
//     if (_subjectController.text.isEmpty ||
//         _descriptionController.text.isEmpty ||
//         _categoryController.text.isEmpty ||
//         _selectedMedia == null) {
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Please fill all fields and select an image')),
//         );
//       }
//       return;
//     }

//     // Check the file extension before submitting
//     String fileExtension = _selectedMedia!.path.split('.').last.toLowerCase();
//     _logger.d("File extension before submission: $fileExtension");

//     if (fileExtension != 'jpg' &&
//         fileExtension != 'jpeg' &&
//         fileExtension != 'png') {
//       _logger.w("Unsupported file format: $fileExtension");
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Only JPG, JPEG, and PNG formats are allowed.')),
//         );
//       }
//       return;
//     }

//     setState(() => _isSubmitting = true);
//     var url = Uri.parse("https://egov-backend.vercel.app/api/file/complain");

//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('accessToken');

//     if (token == null) {
//       _logger.w("No token found. Redirecting to login.");
//       if (!mounted) return;
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Session expired. Please log in again.')),
//         );
//       }
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => LoginScreen()));
//       }
//       return;
//     }

//     var request = http.MultipartRequest("POST", url);
//     request.headers['Authorization'] = "Bearer $token";
//     request.fields['subject'] = _subjectController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['category'] = _categoryController.text;
//     request.files.add(
//       await http.MultipartFile.fromPath('image', _selectedMedia!.path),
//     );

//     _logger.i("Submitting complaint...");
//     _logger.d("Subject: ${_subjectController.text}");
//     _logger.d("Description: ${_descriptionController.text}");
//     _logger.d("Category: ${_categoryController.text}");
//     _logger.d("Image Path: ${_selectedMedia!.path}");
//     _logger.d("Image Format: $fileExtension");
//     _logger.d("Token: $token");

//     try {
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = jsonDecode(responseData);

//       _logger.i("API Response Status: ${response.statusCode}");
//       _logger.d("API Response Body: $jsonResponse");

//       setState(() {
//         _apiResponse = jsonResponse['message'] ?? 'Complaint submitted!';
//       });
//       if (!mounted) return;
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(_apiResponse)),
//         );
//       }
//     } catch (e) {
//       _logger.e("Error submitting complaint: $e");
//       if (!mounted) return;
//       if (context.mounted) {
//         // Ensure the widget is still mounted
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit complaint')),
//         );
//       }
//     }

//     setState(() => _isSubmitting = false);
//   }

//   Future<void> _logout() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
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
//     if (!mounted) return;
//     Navigator.pop(context);
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => LoginScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xffB81736),
//         title: Text("Add Complaint", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, color: Colors.white),
//             color: Colors.white,
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _logout();
//               }
//             },
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
//             ],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _subjectController,
//                 decoration: InputDecoration(
//                   labelText: 'Subject',
//                   hintText: 'Enter the subject of your complaint',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.subject),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   hintText: 'Describe your complaint in detail',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.description),
//                 ),
//                 maxLines: 5,
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _categoryController,
//                 decoration: InputDecoration(
//                   labelText: 'Category',
//                   hintText: 'Enter the category of your complaint',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.category),
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildMediaPicker(),
//               SizedBox(height: 20),
//               _isSubmitting
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _submitComplaint,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xffB81736),
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                       ),
//                       child: Text(
//                         "Submit Complaint",
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//               SizedBox(height: 20),
//               _apiResponse.isNotEmpty
//                   ? Text(
//                       "Response: $_apiResponse",
//                       style: TextStyle(
//                           color: Colors.green, fontWeight: FontWeight.bold),
//                     )
//                   : SizedBox(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMediaPicker() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (_selectedMedia != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.file(
//               _selectedMedia!,
//               height: 200,
//               width: 200,
//               fit: BoxFit.cover,
//             ),
//           )
//         else
//           const Text(
//             'No media selected',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: () => _pickMedia(ImageSource.camera),
//               icon: const Icon(Icons.camera_alt),
//               label: const Text('Camera'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xffB81736),
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               ),
//             ),
//             const SizedBox(width: 10),
//             ElevatedButton.icon(
//               onPressed: () => _pickMedia(ImageSource.gallery),
//               icon: const Icon(Icons.photo_library),
//               label: const Text('Gallery'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xffB81736),
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  AddComplaintScreenState createState() => AddComplaintScreenState();
}

class AddComplaintScreenState extends State<AddComplaintScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedMedia;
  bool _isSubmitting = false;
  String _apiResponse = ""; // Stores API response message

  final Logger _logger = Logger();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        // Check the file extension
        String fileExtension = pickedFile.path.split('.').last.toLowerCase();
        _logger.d("Selected file extension: $fileExtension");

        if (fileExtension != 'jpg' &&
            fileExtension != 'jpeg' &&
            fileExtension != 'png') {
          _logger.w("Unsupported file format: $fileExtension");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Only JPG, JPEG, and PNG formats are allowed.')),
          );
          return;
        }

        setState(() {
          _selectedMedia = File(pickedFile.path);
        });
        _logger.i("Media selected: ${_selectedMedia!.path}");
      } else {
        _logger.w("No media selected.");
      }
    } catch (e) {
      _logger.e("Error picking media: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }

  Future<void> _submitComplaint() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _selectedMedia == null) {
      if (context.mounted) {
        // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all fields and select an image')),
        );
      }
      return;
    }

    // Check the file extension before submitting
    String fileExtension = _selectedMedia!.path.split('.').last.toLowerCase();
    _logger.d("File extension before submission: $fileExtension");

    if (fileExtension != 'jpg' &&
        fileExtension != 'jpeg' &&
        fileExtension != 'png') {
      _logger.w("Unsupported file format: $fileExtension");
      if (context.mounted) {
        // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Only JPG, JPEG, and PNG formats are allowed.')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    var url = Uri.parse("https://egov-backend.vercel.app/api/file/complain");

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      _logger.w("No token found. Redirecting to login.");
      if (!mounted) return;
      if (context.mounted) {
        // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
      }
      if (context.mounted) {
        // Ensure the widget is still mounted
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
      return;
    }

    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = "Bearer $token";
    request.fields['subject'] = _subjectController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['category'] = _categoryController.text;
    request.files.add(
      await http.MultipartFile.fromPath('image', _selectedMedia!.path),
    );

    _logger.i("Submitting complaint...");
    _logger.d("Subject: ${_subjectController.text}");
    _logger.d("Description: ${_descriptionController.text}");
    _logger.d("Category: ${_categoryController.text}");
    _logger.d("Image Path: ${_selectedMedia!.path}");
    _logger.d("Image Format: $fileExtension");
    _logger.d("Token: $token");

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      _logger.i("API Response Status: ${response.statusCode}");
      _logger.d("API Response Body: $jsonResponse");

      setState(() {
        _apiResponse = jsonResponse['message'] ?? 'Complaint submitted!';
      });
      if (!mounted) return;
      if (context.mounted) {
        // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_apiResponse)),
        );
      }
    } catch (e) {
      _logger.e("Error submitting complaint: $e");
      if (!mounted) return;
      if (context.mounted) {
        // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint')),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffB81736),
        title: const Text("Add Complaint", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'Enter the subject of your complaint',
                icon: Icons.subject,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your complaint in detail',
                icon: Icons.description,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _categoryController,
                label: 'Category',
                hint: 'Enter the category of your complaint',
                icon: Icons.category,
              ),
              const SizedBox(height: 20),
              _buildMediaPicker(),
              const SizedBox(height: 30),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffB81736),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Complaint",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_apiResponse.isNotEmpty)
                Text(
                  "Response: $_apiResponse",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildMediaPicker() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedMedia != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _selectedMedia!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text(
                'No media selected',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: () => _pickMedia(ImageSource.camera),
                ),
                _buildMediaButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () => _pickMedia(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffB81736),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}