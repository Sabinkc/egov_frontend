import 'package:egov_project/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegScreen extends StatelessWidget {
  const RegScreen({super.key});

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
                      const TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.check, color: Colors.grey),
                          labelText: 'Full Name',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.check, color: Colors.grey),
                          labelText: 'Phone or Gmail',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          suffixIcon:
                              Icon(Icons.visibility_off, color: Colors.grey),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          suffixIcon:
                              Icon(Icons.visibility_off, color: Colors.grey),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
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
                          child: const Center(
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
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
                                "Sign in",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
