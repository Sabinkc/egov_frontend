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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 500),
            content: Center(
              child: Text(
                "Complaint Edited Successfully!",
                style: TextStyle(color: Colors.white),
              ),
            )));
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
        automaticallyImplyLeading: false,
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
          "Edit Complaint",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Text Field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.subject, color: Colors.grey),
              ),
            ),

            SizedBox(height: 10),

            // Description Text Field
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.description, color: Colors.grey),
                alignLabelWithHint:
                    true, // Aligns label properly for multiline text fields
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.category, color: Colors.grey),
              ),
            ),

            SizedBox(height: 10),

            // Image Picker
            Center(
              child: Text(
                "Pick an image to change",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adds rounded corners
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : widget.complaint['imageUrl'] != null
                        ? Image.network(
                            widget.complaint['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholder(),
                          )
                        : _placeholder(),
              ),
            ),
            SizedBox(height: 10),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),

            // Update Button
            Center(
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateComplaint,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffB81736),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: _isUpdating
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Update Complaint",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Matches image border
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
      ),
    );
  }
}
