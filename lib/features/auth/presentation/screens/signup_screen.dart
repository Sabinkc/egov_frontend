import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:egov_project/features/auth/data/api_service.dart';
import 'package:egov_project/features/dashboard/presentation/dashboard_screen.dart';
import 'package:logger/logger.dart';
// Import the logger

class RegScreen extends StatefulWidget {
  const RegScreen({super.key});

  @override
  State<RegScreen> createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  bool _isObscure = true; // For toggling password visibility

  // Logger for debugging
  final Logger _logger = Logger();

  // Validation methods
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }
void _signUp() async {
  _logger.i("Starting sign-up process...");

  // Log the current values in the text fields
  _logger.i("Full Name: ${_fullNameController.text}");
  _logger.i("Email: ${_emailController.text}");
  _logger.i("Password: ${_passwordController.text}");

  // Perform validation checks
  final fullNameError = _validateFullName(_fullNameController.text);
  final emailError = _validateEmail(_emailController.text);
  final passwordError = _validatePassword(_passwordController.text);

  // Log the validation results
  _logger.i("Validation Results - Full Name Error: $fullNameError");
  _logger.i("Validation Results - Email Error: $emailError");
  _logger.i("Validation Results - Password Error: $passwordError");

  // Update the state with the validation errors
  setState(() {
    _fullNameError = fullNameError;
    _emailError = emailError;
    _passwordError = passwordError;
  });

  // If any error occurs, stop and show validation messages
  if (fullNameError != null || emailError != null || passwordError != null) {
    _logger.w(
        "Validation failed: Full Name Error: $fullNameError, Email Error: $emailError, Password Error: $passwordError");
    return; // Stop if validation fails
  }

  setState(() {
    _isLoading = true;
  });

  _logger.i("Validation passed, sending sign-up request...");

  try {
    final response = await ApiService.signUp(
      _fullNameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return; // Ensure the widget is still in the tree

    // Log the API response
    _logger.i("API Response: $response");

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("message")) {
      _logger.w("Sign-up failed: ${response["message"]}");
      if (context.mounted) { // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(response["message"] ?? "Sign-up failed")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _logger.i("Sign-up successful, navigating to Dashboard...");

      // Show success SnackBar
      if (context.mounted) { // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Signed up successfully!")),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to Dashboard
      if (context.mounted) { // Ensure the widget is still mounted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  } catch (e) {
    if (!mounted) return; // Ensure the widget is still in the tree

    // Log any exceptions that occur during the API call
    _logger.e("Error during sign-up: $e");

    setState(() {
      _isLoading = false;
    });

    if (context.mounted) { // Ensure the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text("An error occurred: ${e.toString()}")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xffB81736),
                  Color(0xff281537),
                ]),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Create Your\nAccount!',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                          errorText: _fullNameError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Phone or Gmail',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                          errorText: _emailError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _signUp,
                          child: Container(
                            height: 55,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(colors: [
                                Color(0xffB81736),
                                Color(0xff281537),
                              ]),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 190),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
