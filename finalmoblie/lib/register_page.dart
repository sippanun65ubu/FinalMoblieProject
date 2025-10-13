import 'package:flutter/material.dart';
import 'pocketbase_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final pbService = PocketBaseService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    try {
      await pbService.register(emailController.text, passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Register success!')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
