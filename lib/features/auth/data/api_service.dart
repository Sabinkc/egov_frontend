import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  static const String baseUrl = "https://egov-backend.vercel.app/api/users/login"; // Replace with actual API

  static final Logger _logger = Logger();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        _logger.d("Login successful: ${response.body}");
        return jsonDecode(response.body);
      } else {
        _logger.e("Login failed: ${response.statusCode} - ${response.body}");
        return {"message": "Login failed. Please try again.", "errorStack": ""};
      }
    } catch (e) {
      _logger.e("Error during login request: $e");
      return {"message": "An error occurred. Please try again later.", "errorStack": ""};
    }
  }
}
