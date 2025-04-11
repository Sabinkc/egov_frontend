import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://egov-backend.vercel.app/api/users/login"; // Replace with actual API

  static final Logger _logger = Logger();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.i("Starting login request for email: $email");

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        _logger.d("Login successful: ${response.body}");
        final responseData = jsonDecode(response.body);
        
        // Save access token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['accessToken']);

        return responseData;
      } else {
        _logger.w("Login failed: ${response.statusCode} - ${response.body}");
        return {"message": "Login failed. Please try again.", "errorStack": ""};
      }
    } catch (e) {
      _logger.e("Error during login request: $e");
      return {"message": "An error occurred. Please try again later.", "errorStack": ""};
    }
  }

  static Future<Map<String, dynamic>> signUp(String fullName, String email, String password) async {
    _logger.i("Starting sign-up request for email: $email with name: $fullName");

    final requestBody = {
      "username": fullName,
      "email": email,
      "password": password,
    };

    _logger.d("Request body: ${jsonEncode(requestBody)}");
    try {
      final response = await http.post(
        Uri.parse("https://egov-backend.vercel.app/api/users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _logger.d("Sign-up successful: ${response.body}");
        return jsonDecode(response.body);
      } else {
        _logger.w("Sign-up failed: ${response.statusCode} - ${response.body}");
        return {"message": "An error occurred during sign-up", "errorStack": ""};
      }
    } catch (e) {
      _logger.e("Error during sign-up request: $e");
      return {"message": "An error occurred. Please try again later.", "errorStack": ""};
    }
  }

  // Method to retrieve the access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
