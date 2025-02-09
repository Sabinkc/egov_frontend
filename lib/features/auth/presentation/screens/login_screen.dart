import 'package:egov_project/features/auth/data/api_service.dart';
import 'package:egov_project/features/auth/presentation/screens/signup_screen.dart';
import 'package:egov_project/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool isObscure = true;

  // Initialize logger
  final Logger _logger = Logger();

  // Email validation function
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

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  void _login() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError != null || _passwordError != null) {
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context); // Store before await

    try {
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return; // Ensure the widget is still in the tree

      setState(() {
        _isLoading = false;
      });

      _logger.d("Login Response: $response");

      if (response.containsKey("accessToken")) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        _logger.e("Login failed: ${response['message']}");
        messenger.showSnackBar(
          // Use stored messenger instance
          SnackBar(
            content: Center(child: Text(response["message"] ?? "Login failed")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still in the tree

      setState(() {
        _isLoading = false;
      });

      _logger.e("Login failed with error: $e");

      messenger.showSnackBar(
        // Use stored messenger instance
        SnackBar(
          content:
              Center(child: Text("An error occurred. Please try again later.")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height + 20,
          ),
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
                  padding: EdgeInsets.only(top: 110.0, left: 22),
                  child: Text(
                    'Welcome\nSign in!',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 250.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffB81736),
                              ),
                              errorText: _emailError,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => setState(() {
                              _emailError = _validateEmail(value);
                            }),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: isObscure,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                                icon: Icon(
                                  isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffB81736),
                              ),
                              errorText: _passwordError,
                            ),
                            onChanged: (value) => setState(() {
                              _passwordError = _validatePassword(value);
                            }),
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: _isLoading ? null : _login,
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
                                        'SIGN IN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 280),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Sign up",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
