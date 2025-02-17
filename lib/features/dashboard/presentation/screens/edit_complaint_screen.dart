import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const EditComplaintScreen({Key? key, required this.complaint})
      : super(key: key);

  @override
  EditComplaintScreenState createState() => EditComplaintScreenState();
}

class EditComplaintScreenState extends State<EditComplaintScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedImage;
  bool _isUpdating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _subjectController.text = widget.complaint['subject'] ?? '';
    _descriptionController.text = widget.complaint['description'] ?? '';
    _categoryController.text = widget.complaint['category'] ?? '';
  }

  /// Image Picker Function
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Update Complaint API Call
  Future<void> _updateComplaint() async {
    setState(() {
      _isUpdating = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      if (token == null) {
        setState(() {
          _isUpdating = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
        return;
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
            "https://egov-backend.vercel.app/api/file/complain/${widget.complaint['_id']}"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['subject'] = _subjectController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['category'] = _categoryController.text;

      // Attach image if changed
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      var response = await request.send();
      // var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (!mounted) {
          return;
        }
        Navigator.pop(context, true); // Return success
      } else {
        setState(() {
          _errorMessage = 'Failed to update complaint. Try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffB81736),
        title: Text("Edit Complaint"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Text Field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            SizedBox(height: 10),

            // Description Text Field
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),

            // Category Text Field (Manual Entry)
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 10),

            // Image Picker
            Text("Image"),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover)
                  : widget.complaint['imageUrl'] != null
                      ? Image.network(widget.complaint['imageUrl'],
                          height: 200, fit: BoxFit.cover)
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
            ),
            SizedBox(height: 10),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),

            // Update Button
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateComplaint,
              child: _isUpdating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Update Complaint"),
            ),
          ],
        ),
      ),
    );
  }
}
