// import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
// import 'package:flutter/material.dart';

// void main(List<String> args) {
//   runApp(MyApplication());
// }

// class MyApplication extends StatelessWidget {
//   const MyApplication({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginScreen(),
//     );
//   }
// }


import 'package:egov_project/features/auth/presentation/screens/login_screen.dart';
import 'package:egov_project/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final String? token = await getAccessToken();
  runApp(MyApplication(isLoggedIn: token != null));
}

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

class MyApplication extends StatelessWidget {
  final bool isLoggedIn;

  const MyApplication({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? DashboardScreen() : LoginScreen(),
    );
  }
}
