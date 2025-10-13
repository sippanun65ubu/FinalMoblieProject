import 'package:flutter/material.dart';
import 'pocketbase_service.dart';
import 'login_page.dart';
import 'home_page.dart';

final pbService = PocketBaseService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: pbService.isLoggedIn ? HomePage() : LoginPage(),
    );
  }
}
